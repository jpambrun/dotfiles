import { Glob, $ } from "bun";
import { watch } from "fs";
import * as tar from "tar";
import { parseArgs } from "util";

const { values } = parseArgs({
  args: Bun.argv,
  options: {
    namespace: { type: "string" },
    app: { type: "string" },
    src: { type: "string" },
    dst: { type: "string" },
  },
  strict: true,
  allowPositionals: true,
});

const { app, src, dst, namespace } = values;
const podResponse = await $`kubectl -n ${namespace} get pods -l app=${app} -o json`.json();
const podName = podResponse?.items?.[0]?.metadata?.name;
if (!podName) throw new Error("Pod not found");
console.log(`Pod name: ${podName}`);

async function sendFilesToPod(filesToSend, podName, destPath) {
  const tarStream = tar.create({ portable: true }, filesToSend);
  const proc = Bun.spawn(["kubectl", "exec", "-i", podName, "--", "tar", "xf", "-", "-C", destPath], { stdin: "pipe" });

  for await (const chunk of tarStream) {
    proc.stdin.write(chunk);
  }

  await proc.stdin.end();
  await proc.exited;

  return proc.exitCode;
}

const glob = new Glob(src);

const t1 = Date.now();
const files = await Array.fromAsync(glob.scan("."));
const t2 = Date.now();
console.log(`Found ${files.length} files matching ${src} in ${t2 - t1}ms`);
await sendFilesToPod(files, podName, dst);
console.log(`Sent ${files.length} files to pod ${podName} at ${dst}, took ${Date.now() - t2}ms`);

const watcher = watch(process.cwd(), { recursive: true }, async (event, filename) => {
  if (!glob.match(filename)) {
    return;
  }
  console.log(`${event}: ${filename}`);

  if (event === "change" || event === "rename") {
    await sendFilesToPod([filename], podName, dst);
    console.log(`Updated ${filename} in pod ${podName}`);
  }
});

process.on("SIGINT", () => {
  // close watcher when Ctrl-C is pressed
  console.log("Closing watcher...");
  watcher.close();
  process.exit(0);
});
