#!/usr/bin/env -S deno run --allow-net --allow-env --allow-write
import { S3Client } from "https://deno.land/x/s3_lite_client@0.7.0/mod.ts";
import { read } from "https://deno.land/x/streaming_zip/read.ts";
import { PartialReader } from "https://deno.land/x/stream_slicing/partial_reader.ts";
import { Buffer } from "https://deno.land/std@0.195.0/streams/buffer.ts";
import { parseArgs } from "https://deno.land/std@0.221.0/cli/parse_args.ts";

const parsedArgs = parseArgs(Deno.args);
if (!parsedArgs.bucket) throw new Exception('--bucket is required')
if (!parsedArgs?._?.[0]) throw new Exception('path to apk is required')
if (!parsedArgs._[0].endsWith('.apk')) throw new Exception('path needs to ned with .apk')
const filename = parsedArgs._[0].split('/').pop().replace(/.apk$/, '')

const s3client = new S3Client({
    endPoint: "s3.us-east-2.amazonaws.com",
    port: 443,
    useSSL: true,
    region: "us-east-2",
    bucket: parsedArgs.bucket,
    accessKey: Deno.env.get("AWS_ACCESS_KEY_ID"),
    secretKey: Deno.env.get("AWS_SECRET_ACCESS_KEY"),
    sessionToken: Deno.env.get("AWS_SESSION_TOKEN"),
    pathStyle: false,
});

const resp = await s3client.getObject(parsedArgs._[0]);
const partialReader = PartialReader.fromStream(resp.body);

await Deno.mkdir(`${filename}/dicom`, { recursive: true })

for await (const entry of read(partialReader)) {
    if (entry.type === 'directory') continue;
    const buffer = new Buffer();
    await entry.body.stream().pipeTo(buffer.writable);
    if (!entry.name.endsWith('.dcm')) continue
    await Deno.writeFile(`./${filename}/${entry.name}`, buffer.bytes());
    console.log(`Extracted ${entry.name}`)
}


// extractDicomFromApk.js --bucket vida-biobank-landing-bucket-sandbox-743078781022-us-east-2  apk_historical/academic-VIDA/c412df63728b65fca75035b10090ace1/1.3.12.2.1107.5.1.4.60078.30000011110919503346800003276/1.3.12.2.1107.5.1.4.60078.30000011110919503346800000718/JH113680_H-14551_20111109_132145_20200129_174224_export.apk