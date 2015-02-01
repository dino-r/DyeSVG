module ProcessSVG (
   processSVG
) where

import Data.Functor
import qualified Data.Text as T
import Text.XML.Light
import qualified Text.XML.Light.Cursor as Cur

-- Takes the contents of a CSS File and the Contents of an SVG File.
-- Removes all "fill:rgb(...);" and "stroke:rgb(...);" statements from the SVG File.
-- Removes a <style> tag if already present.
-- Inserts the CSS Style into the SVG.
-- Note that we need to remove the fill and stroke statements since they override the CSS Style
processSVG :: String -> String -> Maybe String
processSVG css file = showContent . Cur.toTree 
                      <$> (  (    deleteStyleTag . (removeAttributes attributesToRemove)
                              <$> Cur.fromElement 
                              <$> (parseXMLDoc file)
                             )
                          >>= insertStyle (cssContent css)
                          )

-- Beginning of the strings that should be removed from attribute Lists.
-- The end of the removed strings is given by ';'
attributesToRemove = ["fill:rgb","stroke:rgb"]

--------------------------------------------------

-- Removes all specified attributes recursively in a Cursor
removeAttributes :: [String] -> Cur.Cursor -> Cur.Cursor
removeAttributes [] = id
removeAttributes (x:xs) = (cursorChildMap (removeStringInElement x)).(removeAttributes xs)
   where cursorChildMap f (Cur.Cur c l r p) = Cur.Cur (contentTreeMap f c) l r p
         removeStringInElement needle (Element n attrs c l) = Element n (modAttr needle attrs) c l
         modAttr needle attrs = map (removeStringInAttr needle) attrs

-- removes parts of a string, starting from needle to the following ';' character
removeStringInAttr :: String -> Attr -> Attr
removeStringInAttr needle (Attr qn haystack) = Attr qn removeString
   where removeString = beforeNeedle  ++ afterNeedle 
         beforeNeedle = (T.unpack . fst) $  T.breakOn (T.pack needle) (T.pack haystack)
         afterNeedle  = (T.unpack . T.drop 1 . T.dropWhile (/= ';') . snd) 
                        $ T.breakOn (T.pack needle) (T.pack haystack)


--- maps an Element transformation over a Content tree
contentTreeMap :: (Element -> Element) -> Content -> Content
contentTreeMap f (Elem (Element n attrs conts l)) = 
   Elem $ f (Element n attrs (map (contentTreeMap f) conts) l)
contentTreeMap f other = other



--------------------------------------------------

-- insert the a piece of Content as a child of SVG and return to the root of the document
insertStyle :: Content -> Cur.Cursor -> Maybe Cur.Cursor
insertStyle cont cur = Cur.root <$> (Cur.insertLeft cont <$> svgtag)
   where svgtag = findTag "svg" cur >>= Cur.firstChild

-- figures out where the SVG Element is and moves the Cursor to this position
findTag :: String -> Cur.Cursor -> Maybe Cur.Cursor
findTag tagname cur = if isGivenTag tagname cur
                 then Just cur
                 else Cur.findChild (isGivenTag tagname) cur

-- True if the Cursor points to an Element with the given Tag Name
isGivenTag :: String -> Cur.Cursor -> Bool
isGivenTag str cur = 
   case Cur.current cur of
      Elem elem -> if (qName . Cur.tagName . Cur.getTag) elem == str then True else False 
      _         -> False

--------------------------------------------------
-- If there's already a <style> tag, we need to remove it
deleteStyleTag :: Cur.Cursor -> Cur.Cursor
deleteStyleTag cur = case result of
                        Just x -> x
                        Nothing -> cur
   where result = Cur.root <$> (findTag "style" cur >>= Cur.removeGoUp)



--------------------------------------------------
-- CSS Style Content: cssContent wraps a string into a Content Type
cssContent :: String -> Content
cssContent str = Elem (Element styleTag [] [cont] Nothing)
   where styleTag = QName "style" Nothing Nothing
         cont     = Text (CData CDataText str Nothing) 
