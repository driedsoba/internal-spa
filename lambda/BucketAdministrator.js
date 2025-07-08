import { S3Client, CreateBucketCommand, DeleteBucketCommand, PutBucketPolicyCommand, GetBucketPolicyCommand, PutBucketLifecycleConfigurationCommand, PutBucketCorsCommand } from '@aws-sdk/client-s3';

const s3Client = new S3Client({});

export const handler = async (event) => {
    console.log('Event received:', JSON.stringify(event, null, 2));
    const { action, bucketName, policy, lifecycleConfig } = JSON.parse(event.body || '{}');
    console.log('Action:', action, 'Bucket:', bucketName, 'LifecycleConfig:', JSON.stringify(lifecycleConfig));

    try {
        switch (action) {
            case 'createBucket':
                return await createBucket(bucketName);
            case 'deleteBucket':
                return await deleteBucket(bucketName);
            case 'updatePolicy':
                return await updateBucketPolicy(bucketName, policy);
            case 'getPolicy':
                return await getBucketPolicy(bucketName);
            case 'setLifecycle':
                return await setBucketLifecycle(bucketName, lifecycleConfig);
            default:
                throw new Error('Unknown action');
        }
    } catch (error) {
        console.error('Error details:', error);
        return formatResponse(500, { error: error.message });
    }
};

async function createBucket(bucketName) {
    // Create Bucket
    const command = new CreateBucketCommand({
        Bucket: bucketName,
        CreateBucketConfiguration: {
            LocationConstraint: 'ap-southeast-1'
        }
    });
    await s3Client.send(command);

    // Set n header
    const corsCommand = new PutBucketCorsCommand({
        Bucket: bucketName,
        CORSConfiguration: {
            CORSRules: [{
                AllowedHeaders: ["*"],
                AllowedMethods: ["PUT", "GET", "POST"],
                AllowedOrigins: ["https://dev.chatwithjunle.com"],
                ExposeHeaders: ["ETag", "x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
            }]
        }
    });
    await s3Client.send(corsCommand);
    return formatResponse(200, { message: 'Bucket created with CORS configured' });
}

async function deleteBucket(bucketName) {
    const command = new DeleteBucketCommand({ Bucket: bucketName });
    await s3Client.send(command);
    return formatResponse(200, { message: 'Bucket deleted successfully' });
}

async function updateBucketPolicy(bucketName, policy) {
    const command = new PutBucketPolicyCommand({
        Bucket: bucketName,
        Policy: JSON.stringify(policy)
    });
    await s3Client.send(command);
    return formatResponse(200, { message: 'Policy updated successfully' });
}

async function getBucketPolicy(bucketName) {
    try {
        const command = new GetBucketPolicyCommand({ Bucket: bucketName });
        const response = await s3Client.send(command);
        return formatResponse(200, { policy: JSON.parse(response.Policy) });
    } catch (error) {
        if (error.name === 'NoSuchBucketPolicy') {
            return formatResponse(200, { policy: null });
        }
        throw error;
    }
}
async function setBucketLifecycle(bucketName, lifecycleConfig) {
    console.log('Setting lifecycle for bucket:', bucketName);
    console.log('Config:', JSON.stringify(lifecycleConfig));

    const command = new PutBucketLifecycleConfigurationCommand({
        Bucket: bucketName,
        LifecycleConfiguration: lifecycleConfig
    });
    await s3Client.send(command);
    return formatResponse(200, { message: 'Lifecycle rules updated' });
}


function formatResponse(statusCode, body) {
    return {
        statusCode,
        headers: {
            'Access-Control-Allow-Origin': 'https://dev.chatwithjunle.com',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'OPTIONS,POST'
        },
        body: JSON.stringify(body)
    };
}