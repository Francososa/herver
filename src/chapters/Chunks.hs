{-# LANGUAGE TypeApplications #-}
module Chunks where

import System.IO
import qualified Data.Text as T
import qualified Data.Text.IO as T


hello :: IO ()
hello = T.hPutStrLn stdout (T.pack "hello world!")

printCapitalizedText :: IO ()
printCapitalizedText = 
  withFile "greeting.txt" ReadMode $ \h ->
    forChunks_ (T.hGetChunk h) T.null $ \chunk ->
      T.putStr (T.toUpper chunk)


forChunks_ ::
  IO chunk              -- ^ Producer of chunks
  -> (chunk -> Bool)    -- ^ Does chunk indicate EOF?
  -> (chunk -> IO x)    -- ^ What to do with each chunk  
  -> IO ()
forChunks_ getChunk isEnd f = continue
  where
    continue =
      do
        chunk <- getChunk
        case (isEnd chunk) of
          True -> return ()
          False ->
            do
              _ <- f chunk
              continue

digitsOnly :: T.Text -> T.Text
digitsOnly s = T.pack $ filter isDigit $ T.unpack s
  where
    isDigit = \c -> c `elem` ['0'..'9']