{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad (forM_)

import Text.Blaze.Renderer.Utf8 (renderMarkup)

import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

import qualified Data.ByteString.Lazy as BS
import Data.Functor
import Network
import Control.Concurrent
import System.IO
import System.Posix.Signals

msg = renderMarkup $ H.docTypeHtml $ do
  H.head $ do
    H.title "Amedeo's site"
  H.body $ do  
    H.p "THIS IS THE PAGE!"

handler sock = do
    sClose sock
    putStrLn "Ending Program"
        
page h content = do
  let putStr = hPutStr h 
  putStr "HTTP/1.0 200 OK\r\nContent-Length: "
  putStr $ show $ BS.length content
  putStr "\r\n\r\n"
  BS.hPut h content
  putStr "\r\n"
  
main = withSocketsDo $ do
  socket <- listenOn $ PortNumber 1337
  installHandler sigINT (Catch $ handler socket) Nothing
  sequence_ $ repeat $ do
    (h,_,_) <- accept socket
    forkIO $ do
      page h msg
      hFlush h
      hClose h