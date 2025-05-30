const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');

const dynamoDBClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  try {
    for (const record of event.Records) {
      const message = JSON.parse(record.body);
      const { id, user1, user2, age1, age2, score } = message;

      await dynamoDBClient.send(new PutItemCommand({
        TableName: TABLE_NAME,
        Item: {
          id: { S: id },
          user1: { S: user1 },
          age1: { N: age1.toString() },
          user2: { S: user2 },
          age2: { N: age2.toString() },
          score: { N: score.toString() }
        }
      }));
    }

    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Processed successfully' })
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};