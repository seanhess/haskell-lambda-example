{-# LANGUAGE OverloadedStrings  #-}
{-# LANGUAGE NamedFieldPuns  #-}
module WordCount where

import Aws.Lambda
import Data.Maybe (fromMaybe)

handler :: (ApiGatewayRequest String) -> Context () -> IO (Either (ApiGatewayResponse String) (ApiGatewayResponse Int))
handler (ApiGatewayRequest {apiGatewayRequestBody}) _ = do
  let someText = fromMaybe "" apiGatewayRequestBody
  let wordsCount = length (words someText)
  if wordsCount > 0 then
    pure $ Right $ mkApiGatewayResponse 200 [] wordsCount
  else
    pure $ Left $ mkApiGatewayResponse 400 [] "Sorry, your text was empty"
