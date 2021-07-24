{-# LANGUAGE OverloadedStrings     #-}
module Main where

import Aws.Lambda
import qualified WordCount

main :: IO ()
main =
  runLambdaHaskellRuntime
    defaultDispatcherOptions
    (pure ())
    id $ do
      -- You could also register multiple handlers
      addAPIGatewayHandler "handler" WordCount.handler
