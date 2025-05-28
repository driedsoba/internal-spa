const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const s3 = new S3Client();

// Configure allowed file types and max size (in bytes)
const allowedTypes = ['image/jpeg', 'application/pdf', 'text/plain'];
const maxFileSize = 1 * 1024 * 1024; // 1 MB

exports.handler = async (event) => {
  try {
    // Parse the request body
    const body = JSON.parse(event.body);
    const { fileName, contentType, bucket, path, fileSize } = body;

    // Dynamic bucket validation
    const { ListBucketsCommand } = require("@aws-sdk/client-s3");

    // Get allowed buckets dynamically
    const listCommand = new ListBucketsCommand({});
    const bucketData = await s3.send(listCommand);
    const allowedBuckets = bucketData.Buckets
      .map(bucket => bucket.Name)
      .filter(name => name.startsWith('spa-s3-') || name.includes('upload'));

    if (!allowedBuckets.includes(bucket)) {
      return formatResponse(400, { error: 'Invalid bucket selection' });
    }

    // Validate file type
    if (!allowedTypes.includes(contentType)) {
      return formatResponse(400, { error: 'File type not allowed' });
    }

    // Validate file size if provided
    if (fileSize && fileSize > maxFileSize) {
      return formatResponse(400, { error: `File size exceeds ${maxFileSize / (1024 * 1024)} MB limit` });
    }

    // Format the full path
    const fullPath = path ? (path.endsWith('/') ? path : path + '/') + fileName : fileName;

    // Generate pre-signed URL for direct upload
    const signedUrlExpireSeconds = 60 * 5; // 5 minutes

    const command = new PutObjectCommand({
      Bucket: bucket,
      Key: fullPath,
      ContentType: contentType,
    });

    const uploadURL = await getSignedUrl(s3, command, { expiresIn: signedUrlExpireSeconds });

    return formatResponse(200, {
      uploadURL: uploadURL,
      key: fullPath
    });
  } catch (error) {
    console.error('Error generating pre-signed URL', error);
    return formatResponse(500, { error: 'Failed to generate upload URL' });
  }
};

// Helper for CORS headers and response formatting
function formatResponse(statusCode, body) {
  return {
    statusCode: statusCode,
    headers: {
      'Access-Control-Allow-Origin': 'https://spa.chatwithjunle.com',
      'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date',
      'Access-Control-Allow-Methods': 'OPTIONS,POST'
    },
    body: JSON.stringify(body)
  };
}
