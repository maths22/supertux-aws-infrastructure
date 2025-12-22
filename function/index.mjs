import { DynamoDB } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocument } from '@aws-sdk/lib-dynamodb';

const dynamo = DynamoDBDocument.from(new DynamoDB());

const TableName = process.env.TABLE_NAME;

export const handler = async (event) => {

    let body;
    let statusCode = '200';
    const headers = {
        'Content-Type': 'application/json',
    };

    try {
        switch (event.httpMethod) {
            case 'GET':
                const result = await dynamo.scan({ TableName });
                body = result.Items;
                break;
            case 'POST':
                const request = JSON.parse(event.body);
                const date = new Date();
                // Expire after 14 days
                const ttl = Math.floor(date.getTime() / 1000) + 60 * 60 * 24 * 14;
                const dynamoRequest = {
                    TableName,
                    Item: {
                        "url": request.url,
                        "shasum": request.shasum,
                        "branch": request.branch,
                        "size": request.size,
                        "date": date.toISOString(),
                        "ttl": ttl 
                    }
                }
                await dynamo.put(dynamoRequest);
                body = "ok";
                break;
            default:
                throw new Error(`Unsupported method "${event.httpMethod}"`);
        }
    } catch (err) {
        statusCode = '400';
        body = err.message;
    } finally {
        body = JSON.stringify(body);
    }

    return {
        statusCode,
        body,
        headers,
    };
};
