const { DynamoDBClient, GetItemCommand } = require('@aws-sdk/client-dynamodb');

const dynamoDBClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  const start = Date.now(); // Start time for latency measurement
  try {
    const id = event.pathParameters.id;

    const result = await dynamoDBClient.send(new GetItemCommand({
      TableName: TABLE_NAME,
      Key: {
        id: { S: id }
      }
    }));

    if (!result.Item) {
      const latency = Date.now() - start;
      console.log(JSON.stringify({
        level: "Info",
        operation: "GET",
        status: 404,
        latency: latency
      }));
      return {
        statusCode: 404,
        body: JSON.stringify({ error: 'Compatibility result not found' })
      };
    }

    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Info",
      operation: "GET",
      status: 200,
      latency: latency
    }));
    return {
      statusCode: 200,
      body: JSON.stringify({
        id: result.Item.id.S,
        user1: result.Item.user1.S,
        age1: parseInt(result.Item.age1.N),
        user2: result.Item.user2.S,
        age2: parseInt(result.Item.age2.N),
        score: parseFloat(result.Item.score.N)
      })
    };
  } catch (error) {
    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Error",
      operation: "GET",
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