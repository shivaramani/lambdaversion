    FUNCTION_NAME=ingest-redblack-lambda
    DEPLOY_JAR=./target/lambdaversion-1.0-SNAPSHOT.jar
    DEPLOY_REGION=us-east-1

    # Build new Jar
    mvn clean package

    # Get the current active lambda version
    CURRENT_FUNCTION_VERSION=$(aws lambda --region $DEPLOY_REGION list-versions-by-function --function-name $FUNCTION_NAME --query 'Versions[*].[to_number(Version),FunctionName]' | jq '.[-1][0]')
    ECHO "Current Deployed Version - "$CURRENT_FUNCTION_VERSION

    if [ -n "$CURRENT_FUNCTION_VERSION" ]; then 
        echo "Current version is null"
        aws lambda --region $DEPLOY_REGION publish-version --function-name $FUNCTION_NAME
        CURRENT_FUNCTION_VERSION=$(aws lambda --region $DEPLOY_REGION list-versions-by-function --function-name $FUNCTION_NAME --query 'Versions[*].[to_number(Version),FunctionName]' | jq '.[-1][0]')
        ECHO "Getting Current Deployed Version - "$CURRENT_FUNCTION_VERSION
    fi

    # Update the new function and publish a new lambda version
    aws lambda --region $DEPLOY_REGION update-function-code --function-name $FUNCTION_NAME --publish --zip-file fileb://$DEPLOY_JAR 

    # Get the latest new lambda version
    LATEST_FUNCTION_VERSION=$(aws lambda --region $DEPLOY_REGION list-versions-by-function --function-name $FUNCTION_NAME --query 'Versions[*].[to_number(Version),FunctionName]' | jq '.[-1][0]')
    ECHO "Latest Deployed Version - "$LATEST_FUNCTION_VERSION

    # update black(new deployment) and red(old deployment)
    aws lambda --region $DEPLOY_REGION update-alias --function-name $FUNCTION_NAME --name black --function-version $LATEST_FUNCTION_VERSION --description " new  version "
    aws lambda --region $DEPLOY_REGION update-alias --function-name $FUNCTION_NAME --name red --function-version $CURRENT_FUNCTION_VERSION --description " old version "
    
    # set routing config for new and old
    aws lambda  --region $DEPLOY_REGION update-alias --name active --function-name $FUNCTION_NAME --function-version $LATEST_FUNCTION_VERSION  --routing-config AdditionalVersionWeights={$CURRENT_FUNCTION_VERSION=0.5}