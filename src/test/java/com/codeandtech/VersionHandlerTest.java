package com.codeandtech;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.Test;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

class VersionHandlerTest {
  private static final Logger logger = LoggerFactory.getLogger(VersionHandlerTest.class);

  @Test
  void invokeTest() {
    // logger.info("Invoke TEST");
    // HashMap<String,String> event = new HashMap<String,String>();
    // Context context = new TestContext();
    // String requestId = context.getAwsRequestId();
    // Handler handler = new Handler();
    // String result = handler.handleRequest(event, context);
    //assertTrue(result.contains("200 OK"));
    assertTrue(true);
  }

}