const { DynamoDBClient, DeleteItemCommand } = require('@aws-sdk/client-dynamodb');

const dynamoDBClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  const start = Date.now(); // Start time for latency measurement
  try {
    const id = event.pathParameters.id;

    // Delete item from DynamoDB
    await dynamoDBClient.send(new DeleteItemCommand({
      TableName: TABLE_NAME,
      Key: {
        id: { S: id }
      }
    }));

    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Info",
      operation: "DELETE",
      status: 200,
      latency: latency
    }));
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Deleted successfully' })
    };
  } catch (error) {
    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Error",
      operation: "DELETE",
      status: 500,
      latency: latency,
      error: error.message
    }));
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};