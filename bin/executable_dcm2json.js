#!/usr/bin/env -S deno run
import dicomParser from "npm:dicom-parser";
import { standardDataElements } from 'npm:dicom-data-dictionary'


const stdin = await Deno.readAll(Deno.stdin)
const dataSet = dicomParser.parseDicom(stdin, {
    untilTag: "x7fe00010",
})

var options = {
    omitPrivateAttibutes: true,
    maxElementLength: 128
};

var instance = dicomParser.explicitDataSetToJS(dataSet, options);

function renameKeys(source, dest) {
    dest = dest || {}
    for (const key in source) {
        if (key[0] !== 'x' || source[key].dataOffset !== undefined) continue
        const tag = key.slice(1, 9).toUpperCase()
        const newKey = standardDataElements[tag] ? standardDataElements[tag].name : key
        if (source[key] instanceof Array) {
            dest[newKey] = source[key].map(v => renameKeys(v))
        } else if (source[key] instanceof Object) {
            dest[newKey] = renameKeys(source[key])
        } else {
            dest[newKey] = source[key]
        }
    }
    return dest
}

const renamedInstance = renameKeys(instance);

console.log(JSON.stringify(renamedInstance, null, 2))

// fd -e dcm -x sh -c 'cat {} | deno run dcm2json.js {} > {.}.json'
// duckdb :memory: 'select PatientName, InstanceNumber from read_json("*.json", maximum_depth=2, union_by_name=true)'
