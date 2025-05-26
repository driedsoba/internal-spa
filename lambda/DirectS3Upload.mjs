const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const s3 = new S3Client();

exports.handler = async (event) => {
  try {
    // Parse the request body
    const body = JSON.parse(event.body);
    const { fileName, contentType, bucket, path } = body;

    // Validate bucket selection
    const allowedBuckets = ['spa-s3-bucketa', 'spa-s3-bucketb', 'spa-s3-bucketc'];
    if (!allowedBuckets.includes(bucket)) {
      return formatResponse(400, { error: 'Invalid bucket selection' });
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
