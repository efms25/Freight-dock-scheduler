export class UploadFileError extends Error {
    constructor() {
        super(`Upload file error.`)
        this.name = "uploadFileError";
    }
}