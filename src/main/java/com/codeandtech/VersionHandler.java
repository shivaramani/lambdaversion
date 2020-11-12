package codeandtech;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.LambdaLogger;

// TEST DUMMY JAVA LAMBDA
public class VersionHandler implements RequestHandler<InputRequest, String> {

  @Override
  public String handleRequest(final InputRequest inputRequest, final Context context) {
    
    String success_response = "Calling VersionHandler old - ";
    //String success_response = "Calling VersionHandler new - " ;
    System.out.println(success_response);

    return success_response;
    
  }

  
}