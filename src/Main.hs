import System.Environment
import ProcessSVG
import qualified Data.Text as T

main = 
   do
   -- print banner
   banner
   -- get command line arguments
   args <- getArgs
   if ((length args) < 2) then
      usage
   else do
      -- print the Files that are used
      printFileNames args
      -- gather contents of files
      css   <- readFile $ head args      -- first argument is a CSS file
      files <- mapM readFile $ tail args -- all other arguments are SVG files
      -- generate new SVGs 
      writeMultipleFiles (tail args) (processMultipleSVGFiles css files)

processMultipleSVGFiles :: String -> [String] -> [Maybe String]
processMultipleSVGFiles _   []         = []
processMultipleSVGFiles css (svg:tail) = 
   (processSVG css svg):(processMultipleSVGFiles css tail)
                                          
writeMultipleFiles :: [String] -> [Maybe String] -> IO()
writeMultipleFiles [] _ = putStrLn "\nDone."
writeMultipleFiles _ [] = putStrLn "\nDone."
writeMultipleFiles (file:files) (output:outputs) = 
   case output of
      Nothing  -> do putStrLn $ "ERROR in processing " ++ file
                     writeMultipleFiles files outputs
      Just str -> do putStrLn $ "Writing to file " ++ (outputFileName file)
                     writeFile (outputFileName file) str
                     writeMultipleFiles files outputs

-- output file names
outputFileName :: String -> String
outputFileName filename = T.unpack $ T.append ((stripSuffix . T.pack) filename) suffix
   where stripSuffix = T.dropEnd 1 . T.dropWhileEnd (/= '.')
         suffix = T.pack "_dyed.svg"



printFileNames :: [String] -> IO ()
printFileNames (x:xs) = do 
   putStrLn $ "CSS File:  " ++ x
   putStr $ "SVG Files: "
   mapM_ (\x -> putStr (x ++ " ")) xs
   putStrLn ""

--------------------------------------------------
-- Resources -------------------------------------
--------------------------------------------------
banner :: IO ()
banner = do
   putStrLn "-----------------------------"
   putStrLn "--  DyeSVG: Dye your SVGs  --"
   putStrLn "-----------------------------\n"

usage :: IO ()
usage = putStrLn "USAGE: dyesvg <CSS File> <SVG File> [<SVG File> ...]\n\nThe <CSS File> should look like this:\n   svg { fill: #9fb4b6; stroke: #9fb4b6;}\nwhere any valid color in CSS can be chosen.\n\nThe remaining arguments should be SVG Files."



