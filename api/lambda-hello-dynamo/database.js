const AWS = require('aws-sdk');
AWS.config.update({ region: 'us-east-1' });

const TABLE = process.env.DYNAMODB_HELLO;

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export const getItem = (id) => {
    return dynamoDb.get({
        'TableName': TABLE,
        'Key': {
            id: id
        }
    });
};


