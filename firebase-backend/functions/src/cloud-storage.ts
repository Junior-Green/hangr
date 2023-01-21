import path from "path";
import os from "os";
import fs from "fs";
import mkdirp from "mkdirp";
import * as Spawn from "child-process-promise";
import {storage} from "firebase-admin";
import * as Functions from "firebase-functions";
import {CLOUD_REGION} from "./constants";

const functions = Functions.region(CLOUD_REGION);

export class CloudStorage {
    static JPEG_EXTENSION = ".jpg";
    constructor(private storage: storage.Storage) {
    }

    convertToJPG = functions.storage.object().onFinalize(async (object) => {
        const filePath = object.name;
        const contentType = object.contentType;

        if (!filePath || !contentType) {
            return false;
        }

        const spawn = Spawn.spawn;
        const baseFileName = path.basename(filePath, path.extname(filePath));
        const fileDir = path.dirname(filePath);
        const JPEGFilePath = path.normalize(path.format({
            dir: fileDir,
            name: baseFileName,
            ext: CloudStorage.JPEG_EXTENSION,
        }));
        const tempLocalFile = path.join(os.tmpdir(), filePath);
        const tempLocalDir = path.dirname(tempLocalFile);
        const tempLocalJPEGFile = path.join(os.tmpdir(), JPEGFilePath);

        // Exit if this is triggered on a file that is not an image.
        if (contentType.startsWith("image/")) {
            Functions.logger.log("This is not an image.");
            return null;
        }

        // Exit if the image is already a JPEG.
        if (contentType.startsWith("image/jpeg")) {
            console.log("Already a JPEG.");
            return null;
        }

        const bucket = this.storage.bucket(object.bucket);
        // Create the temp directory where the storage file will be downloaded.
        await mkdirp(tempLocalDir);
        // Download file from bucket.
        await bucket.file(filePath).download({destination: tempLocalFile});
        console.log("The file has been downloaded to", tempLocalFile);
        // Convert the image to JPEG using ImageMagick.
        await spawn("convert", [tempLocalFile, tempLocalJPEGFile]);
        console.log("JPEG image created at", tempLocalJPEGFile);
        // Uploading the JPEG image.
        await bucket.upload(tempLocalJPEGFile, {destination: JPEGFilePath});
        console.log("JPEG image uploaded to Storage at", JPEGFilePath);

        // Delete the local files to free up disk space.
        fs.unlinkSync(tempLocalJPEGFile);
        fs.unlinkSync(tempLocalFile);
        return null;
    });
}
