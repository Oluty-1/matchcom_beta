const { DynamoDBClient, DeleteItemCommand } = require('@aws-sdk/client-dynamodb');

const dynamoDBClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  try {
    const id = event.pathParameters.id;

    await dynamoDBClient.send(new DeleteItemCommand({
      TableName: TABLE_NAME,
      Key: {
        id: { S: id }
      }
    }));

    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Deleted successfully' })
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};