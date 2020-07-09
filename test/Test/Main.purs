module Test.Main where

import Prelude

import Data.Either (Either(..))
import Data.Filterable (filterMap, partition, partitionMap, separate)
import Data.Foldable (foldMap, foldl)
import Data.Identity (Identity(..))
import Data.Maybe (Maybe(..), fromJust, isNothing, maybe)
import Data.Monoid.Additive (Additive(..))
import Data.Tuple (Tuple(..))
import Data.Unfoldable (replicateA, replicate, unfoldr)
import Data.Witherable (wilt, wither)
import Effect (Effect)
import Effect.Console (log)
import Data.Traversable (traverse)
import Data.TraversableWithIndex (traverseWithIndex)
import Erl.Data.List (List, alterAt, catMaybes, concat, concatMap, cons, delete, deleteAt, deleteBy, drop, dropWhile, elemIndex, elemLastIndex, filter, findIndex, findLastIndex, foldM, fromFoldable, head, init, insert, insertAt, insertBy, intersect, intersectBy, last, length, mapMaybe, mapWithIndex, modifyAt, nil, nub, nubBy, null, range, reverse, singleton, snoc, sort, sortBy, tail, take, takeWhile, transpose, uncons, union, unionBy, unzip, updateAt, zip, zipWith, zipWithA, (!!), (..), (:), (\\))
import Partial.Unsafe (unsafePartial)
import Test.Assert (assert)

main :: Effect Unit
main = do
  let xs = cons 1 (cons 2 nil)
  let ys = "a" : "b" : "c" : nil

  log "Show instance"
  assert $ show (nil :: List Unit) == "nil"
  assert $ show xs == "(1 : 2 : nil)"
  assert $ show ys == "(\"a\" : \"b\" : \"c\" : nil)"

  assert $ isNothing (uncons nil)
  assert $ maybe false (\{head} -> head == 1) $ uncons xs
  assert $ maybe false (\{head} -> head == "a") $ uncons ys

  assert $ length xs == 2
  assert $ length ys == 3
  assert $ length nil == 0


  testList


  log "Tests passed!"

-- tests from Data.List
testList :: Effect Unit
testList = do
  let l = fromFoldable

  log "singleton should construct an list with a single value"
  assert $ singleton 1 == l [1]
  assert $ singleton "foo" == l ["foo"]
  assert $ singleton (nil :: List Int) == l [l []]

  log "range should create an inclusive list of integers for the specified start and end"
  assert $ (range 0 5) == l [0, 1, 2, 3, 4, 5]
  assert $ (range 2 (-3)) == l [2, 1, 0, -1, -2, -3]

  log "replicate should produce an list containg an item a specified number of times"
  assert $ replicate 3 true == l [true, true, true]
  assert $ replicate 1 "foo" == l ["foo"]
  assert $ replicate 0 "foo" == l []
  assert $ replicate (-1) "foo" == l []

  log "replicateA should perform the monadic action the correct number of times"
  assert $ replicateA 3 (Just 1) == Just (l [1, 1, 1])
  assert $ replicateA 1 (Just 1) == Just (l [1])
  assert $ replicateA 0 (Just 1) == Just (l [])
  assert $ replicateA (-1) (Just 1) == Just (l [])

  -- some
  -- many

  log "null should return false for non-empty lists"
  assert $ null (l [1]) == false
  assert $ null (l [1, 2, 3]) == false

  log "null should return true for an empty list"
  assert $ null (nil :: List Int) == true

  log "length should return the number of items in an list"
  assert $ length (nil :: List Int) == 0
  assert $ length (l [1]) == 1
  assert $ length (l [1, 2, 3, 4, 5]) == 5

  log "length should be stack-safe"
  void $ pure $ length (range 1 100000)
  
  log "snoc should add an item to the end of an list"
  assert $ l [1, 2, 3] `snoc` 4 == l [1, 2, 3, 4]
  assert $ nil `snoc` 1 == l [1]
  
  log "insert should add an item at the appropriate place in a sorted list"
  assert $ insert 1.5 (l [1.0, 2.0, 3.0]) == l [1.0, 1.5, 2.0, 3.0]
  assert $ insert 4 (l [1, 2, 3]) == l [1, 2, 3, 4]
  assert $ insert 0 (l [1, 2, 3]) == l [0, 1, 2, 3]
  
  log "insertBy should add an item at the appropriate place in a sorted list using the specified comparison"
  assert $ insertBy (flip compare) 4 (l [1, 2, 3]) == l [4, 1, 2, 3]
  assert $ insertBy (flip compare) 0 (l [1, 2, 3]) == l [1, 2, 3, 0]

  log "head should return a Just-wrapped first value of a non-empty list"
  assert $ head (l ["foo", "bar"]) == Just "foo"

  log "head should return Nothing for an empty list"
  assert $ head (nil :: List String) == Nothing

  log "last should return a Just-wrapped last value of a non-empty list"
  assert $ last (l ["foo", "bar"]) == Just "bar"

  log "last should return Nothing for an empty list"
  assert $ last (nil :: List Unit) == Nothing

  log "tail should return a Just-wrapped list containing all the items in an list apart from the first for a non-empty list"
  assert $ tail (l ["foo", "bar", "baz"]) == Just (l ["bar", "baz"])

  log "tail should return Nothing for an empty list"
  assert $ tail (nil :: List Unit) == Nothing

  log "init should return a Just-wrapped list containing all the items in an list apart from the first for a non-empty list"
  assert $ init (l ["foo", "bar", "baz"]) == Just (l ["foo", "bar"])

  log "init should return Nothing for an empty list"
  assert $ init (nil :: List Unit) == Nothing

  log "uncons should return nothing when used on an empty list"
  assert $ isNothing (uncons nil)

  log "uncons should split an list into a head and tail record when there is at least one item"
  let u1 = uncons (l [1])
  assert $ unsafePartial (fromJust u1).head == 1
  assert $ unsafePartial (fromJust u1).tail == l []
  let u2 = uncons (l [1, 2, 3])
  assert $ unsafePartial (fromJust u2).head == 1
  assert $ unsafePartial (fromJust u2).tail == l [2, 3]
  
  log "(!!) should return Just x when the index is within the bounds of the list"
  assert $ l [1, 2, 3] !! 0 == (Just 1)
  assert $ l [1, 2, 3] !! 1 == (Just 2)
  assert $ l [1, 2, 3] !! 2 == (Just 3)
  
  log "(!!) should return Nothing when the index is outside of the bounds of the list"
  assert $ l [1, 2, 3] !! 6 == Nothing
  assert $ l [1, 2, 3] !! (-1) == Nothing
  
  log "elemIndex should return the index of an item that a predicate returns true for in an list"
  assert $ elemIndex 1 (l [1, 2, 1]) == Just 0
  assert $ elemIndex 4 (l [1, 2, 1]) == Nothing
  
  log "elemLastIndex should return the last index of an item in an list"
  assert $ elemLastIndex 1 (l [1, 2, 1]) == Just 2
  assert $ elemLastIndex 4 (l [1, 2, 1]) == Nothing
  
  log "findIndex should return the index of an item that a predicate returns true for in an list"
  assert $ findIndex (_ /= 1) (l [1, 2, 1]) == Just 1
  assert $ findIndex (_ == 3) (l [1, 2, 1]) == Nothing
  
  log "findLastIndex should return the last index of an item in an list"
  assert $ findLastIndex (_ /= 1) (l [2, 1, 2]) == Just 2
  assert $ findLastIndex (_ == 3) (l [2, 1, 2]) == Nothing
  
  log "insertAt should add an item at the specified index"
  assert $ (insertAt 0 1 (l [2, 3])) == Just (l [1, 2, 3])
  assert $ (insertAt 1 1 (l [2, 3])) == Just (l [2, 1, 3])
  assert $ (insertAt 2 1 (l [2, 3])) == Just (l [2, 3, 1])
  
  log "insertAt should return Nothing if the index is out of range"
  assert $ (insertAt 2 1 nil) == Nothing
  
  log "deleteAt should remove an item at the specified index"
  assert $ (deleteAt 0 (l [1, 2, 3])) == Just (l [2, 3])
  assert $ (deleteAt 1 (l [1, 2, 3])) == Just (l [1, 3])
  
  log "deleteAt should return Nothing if the index is out of range"
  assert $ (deleteAt 1 (nil :: List Int)) == Nothing
  
  log "updateAt should replace an item at the specified index"
  assert $ (updateAt 0 9 (l [1, 2, 3])) == Just (l [9, 2, 3])
  assert $ (updateAt 1 9 (l [1, 2, 3])) == Just (l [1, 9, 3])
  
  log "updateAt should return Nothing if the index is out of range"
  assert $ (updateAt 1 9 (nil :: List Int)) == Nothing
  
  log "modifyAt should update an item at the specified index"
  assert $ (modifyAt 0 (_ + 1) (l [1, 2, 3])) == Just (l [2, 2, 3])
  assert $ (modifyAt 1 (_ + 1) (l [1, 2, 3])) == Just (l [1, 3, 3])
  
  log "modifyAt should return Nothing if the index is out of range"
  assert $ (modifyAt 1 (_ + 1) nil) == Nothing
  
  log "alterAt should update an item at the specified index when the function returns Just"
  assert $ (alterAt 0 (Just <<< (_ + 1)) (l [1, 2, 3])) == Just (l [2, 2, 3])
  assert $ (alterAt 1 (Just <<< (_ + 1)) (l [1, 2, 3])) == Just (l [1, 3, 3])
  
  log "alterAt should drop an item at the specified index when the function returns Nothing"
  assert $ (alterAt 0 (const Nothing) (l [1, 2, 3])) == Just (l [2, 3])
  assert $ (alterAt 1 (const Nothing) (l [1, 2, 3])) == Just (l [1, 3])
  
  log "alterAt should return Nothing if the index is out of range"
  assert $ (alterAt 1 (Just <<< (_ + 1)) nil) == Nothing
  
  log "reverse should reverse the order of items in an list"
  assert $ (reverse (l [1, 2, 3])) == l [3, 2, 1]
  assert $ (reverse (nil :: List Int)) == nil
  
  log "concat should join an list of lists"
  assert $ (concat (l [l [1, 2], l [3, 4]])) == l [1, 2, 3, 4]
  assert $ (concat (l [l [1], nil])) == l [1]
  assert $ (concat (l [nil, nil])) == (nil :: List Int)

  log "concatMap should be equivalent to (concat <<< map)"
  assert $ concatMap doubleAndOrig (l [1, 2, 3]) == concat (map doubleAndOrig (l [1, 2, 3]))

  log "filter should remove items that don't match a predicate"
  assert $ filter odd (range 0 10) == l [1, 3, 5, 7, 9]
  --
  -- log "filterM should remove items that don't match a predicate while using a monadic behaviour"
  -- assert $ filterM (Just <<< odd) (range 0 10) == Just (l [1, 3, 5, 7, 9])
  -- assert $ filterM (const Nothing) (range 0 10) == Nothing
  --
  log "mapMaybe should transform every item in an list, throwing out Nothing values"
  assert $ mapMaybe (\x -> if x /= 0 then Just x else Nothing) (l [0, 1, 0, 0, 2, 3]) == l [1, 2, 3]
  
  log "catMaybe should take an list of Maybe values and throw out Nothings"
  assert $ catMaybes (l [Nothing, Just 2, Nothing, Just 4]) == l [2, 4]
  
  log "mapWithIndex should take a list of values and apply a function which also takes the index into account"
  assert $ mapWithIndex (\x ix -> x + ix) (fromFoldable [0, 1, 2, 3]) == fromFoldable [0, 2, 4, 6]
  
  log "sort should reorder a list into ascending order based on the result of compare"
  assert $ sort (l [1, 3, 2, 5, 6, 4]) == l [1, 2, 3, 4, 5, 6]
  
  log "sortBy should reorder a list into ascending order based on the result of a comparison function"
  assert $ sortBy (flip compare) (l [1, 3, 2, 5, 6, 4]) == l [6, 5, 4, 3, 2, 1]
  
  log "take should keep the specified number of items from the front of an list, discarding the rest"
  assert $ (take 1 (l [1, 2, 3])) == l [1]
  assert $ (take 2 (l [1, 2, 3])) == l [1, 2]
  assert $ (take 1 nil) == (nil :: List Int)
  
  log "takeWhile should keep all values that match a predicate from the front of an list"
  assert $ (takeWhile (_ /= 2) (l [1, 2, 3])) == l [1]
  assert $ (takeWhile (_ /= 3) (l [1, 2, 3])) == l [1, 2]
  assert $ (takeWhile (_ /= 1) nil) == (nil :: List Int)
  
  log "drop should remove the specified number of items from the front of an list"
  assert $ (drop 1 (l [1, 2, 3])) == l [2, 3]
  assert $ (drop 2 (l [1, 2, 3])) == l [3]
  assert $ (drop 1 nil) == (nil :: List Int)
  
  log "dropWhile should remove all values that match a predicate from the front of an list"
  assert $ (dropWhile (_ /= 1) (l [1, 2, 3])) == l [1, 2, 3]
  assert $ (dropWhile (_ /= 2) (l [1, 2, 3])) == l [2, 3]
  assert $ (dropWhile (_ /= 1) nil) == (nil :: List Int)
  --
  -- log "span should split an list in two based on a predicate"
  -- let spanResult = span (_ < 4) (l [1, 2, 3, 4, 5, 6, 7])
  -- assert $ spanResult.init == l [1, 2, 3]
  -- assert $ spanResult.rest == l [4, 5, 6, 7]
  --
  -- log "group should group consecutive equal elements into lists"
  -- assert $ group (l [1, 2, 2, 3, 3, 3, 1]) == l [l [1], l [2, 2], l [3, 3, 3], l [1]]
  --
  -- log "group' should sort then group consecutive equal elements into lists"
  -- assert $ group' (l [1, 2, 2, 3, 3, 3, 1]) == l [l [1, 1], l [2, 2], l [3, 3, 3]]
  --
  -- log "groupBy should group consecutive equal elements into lists based on an equivalence relation"
  -- assert $ groupBy (\x y -> odd x && odd y) (l [1, 1, 2, 2, 3, 3]) == l [l [1, 1], l [2], l [2], l [3, 3]]
  --
  log "nub should remove duplicate elements from the list, keeping the first occurence"
  assert $ nub (l [1, 2, 2, 3, 4, 1]) == l [1, 2, 3, 4]
  
  log "nubBy should remove duplicate items from the list using a supplied predicate"
  let nubPred = \x y -> if odd x then false else x == y
  assert $ nubBy nubPred (l [1, 2, 2, 3, 3, 4, 4, 1]) == l [1, 2, 3, 3, 4, 1]
  
  log "union should produce the union of two lists"
  assert $ union (l [1, 2, 3]) (l [2, 3, 4]) == l [1, 2, 3, 4]
  assert $ union (l [1, 1, 2, 3]) (l [2, 3, 4]) == l [1, 1, 2, 3, 4]
  
  log "unionBy should produce the union of two lists using the specified equality relation"
  assert $ unionBy (\_ y -> y < 5) (l [1, 2, 3]) (l [2, 3, 4, 5, 6]) == l [1, 2, 3, 5, 6]
  
  log "delete should remove the first matching item from an list"
  assert $ delete 1 (l [1, 2, 1]) == l [2, 1]
  assert $ delete 2 (l [1, 2, 1]) == l [1, 1]
  
  log "deleteBy should remove the first equality-relation-matching item from an list"
  assert $ deleteBy (/=) 2 (l [1, 2, 1]) == l [2, 1]
  assert $ deleteBy (/=) 1 (l [1, 2, 1]) == l [1, 1]
  
  log "(\\\\) should return the difference between two lists"
  assert $ l [1, 2, 3, 4, 3, 2, 1] \\ l [1, 1, 2, 3] == l [4, 3, 2]
  
  log "intersect should return the intersection of two lists"
  assert $ intersect (l [1, 2, 3, 4, 3, 2, 1]) (l [1, 1, 2, 3]) == l [1, 2, 3, 3, 2, 1]
  
  log "intersectBy should return the intersection of two lists using the specified equivalence relation"
  assert $ intersectBy (\x y -> (x * 2) == y) (l [1, 2, 3]) (l [2, 6]) == l [1, 3]
  
  log "zipWith should use the specified function to zip two lists together"
  assert $ zipWith (\x y -> l [show x, y]) (l [1, 2, 3]) (l ["a", "b", "c"]) == l [l ["1", "a"], l ["2", "b"], l ["3", "c"]]
  
  log "zipWithA should use the specified function to zip two lists together"
  assert $ zipWithA (\x y -> Just $ Tuple x y) (l [1, 2, 3]) (l ["a", "b", "c"]) == Just (l [Tuple 1 "a", Tuple 2 "b", Tuple 3 "c"])
  
  log "zip should use the specified function to zip two lists together"
  assert $ zip (l [1, 2, 3]) (l ["a", "b", "c"]) == l [Tuple 1 "a", Tuple 2 "b", Tuple 3 "c"]
  
  log "unzip should deconstruct a list of tuples into a tuple of lists"
  assert $ unzip (l [Tuple 1 "a", Tuple 2 "b", Tuple 3 "c"]) == Tuple (l [1, 2, 3]) (l ["a", "b", "c"])
  
  log "foldM should perform a fold using a monadic step function"
  assert $ foldM (\x y -> Just (x + y)) 0 (range 1 10) == Just 55
  assert $ foldM (\_ _ -> Nothing) 0 (range 1 10) == Nothing

  log "foldl should be stack-safe"
  void $ pure $ foldl (+) 0 $ range 1 100000

  log "foldMap should be stack-safe"
  void $ pure $ foldMap Additive $ range 1 100000

  log "foldMap should be left-to-right"
  log $ foldMap show (range 1 5)
  assert $ foldMap show (range 1 5) == "12345"

  log "unfoldable replicate should be stack-safe"
  void $ pure $ length $ replicate 100000 1

  log "unfoldr should maintain order"
  assert $ (1..5) == unfoldr step 1
  --
  -- -- log "can find the first 10 primes using lazy lists"
  -- -- let eratos :: L.List Number -> L.List Number
  -- --     eratos xs = Control.Lazy.defer \_ ->
  -- --       case L.uncons xs of
  -- --         Nothing -> L.nil
  -- --         Just (Tuple p xs) -> p `L.cons` eratos (L.filter (\x -> x % p /= 0) xs)
  --
  -- --     upFrom = L.iterate (1 +)
  --
  -- --     primes = eratos $ upFrom 2
  -- -- assert $ L.fromList (L.take 10 primes) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
  --
  log "transpose"
  assert $ transpose (l [l [1,2,3], l[4,5,6], l [7,8,9]]) ==
                     (l [l [1,4,7], l[2,5,8], l [3,6,9]])
  log "transpose skips elements when rows don't match"
  assert $ transpose ((10:11:nil) : (20:nil) : nil : (30:31:32:nil) : nil) ==
                     ((10:20:30:nil) : (11:31:nil) : (32:nil) : nil)
  log "transpose Nil == Nil"
  assert $ transpose nil == (nil :: List (List Int))
  log "transpose (singleton Nil) == Nil"
  assert $ transpose (singleton nil) == (nil :: List (List Int))


  log "traverse should be stack-safe"
  let xs = fromFoldable (range 1 100000)
  assert $ traverse Just xs == Just xs

  log "traverseWithIndex should be stack-safe"
  assert $ traverseWithIndex (const Just) xs == Just xs

  log "traverseWithIndex should be correct"
  assert $ traverseWithIndex (\i a -> Just $ i + a) (fromFoldable [2, 2, 2])
           == Just (fromFoldable [2, 3, 4])


  -- Tests from Filterable

  log "Test filterableList instance" *> do
    let testlist = (1 : 2 : 3 : 4 : 5 : 6 : 7 : 8 : 9 : nil)
    assert $ filterMap pred testlist == (60 : 70 : 80 : 90 : nil)
    assert $ filter (_ > 5) testlist == (6 : 7 : 8 : 9 : nil)
    assert $ partition (_ > 5) testlist `testEqNoYes` { no: (1 : 2 : 3 : 4 : 5 : nil), yes: (6 : 7 : 8 : 9 : nil)}
    assert $ (partitionMap Right $ (1 : 2 : 3 : 4 : 5 : nil)).right == (1 : 2 : 3 : 4 : 5 : nil)
    assert $ (partitionMap Left $ (1 : 2 : 3 : 4 : 5 : nil)).left == (1 : 2 : 3 : 4 : 5 : nil)

  log "Test compactableList instance" *> do
    let testList = (Left 1 : Right 2 : Left 3 : Right 4 : Left 5 : Right 6 : Left 7 : Right 8 : nil)
    let parts = separate testList
    assert $ parts.left == (1 : 3 : 5 : 7 : nil)
    assert $ parts.right == (2 : 4 : 6 : 8 : nil)

  log "Test witherableList instance" *> do
    let testlist = (1 : 2 : 3 : 4 : 5 : 6 : 7 : 8 : 9 : nil)
    let resultWilt = wilt predE testlist
    assert $ map _.right resultWilt == Identity (60 : 70 : 80 : 90 : nil)
    assert $ map _.left resultWilt == Identity (1 : 2 : 3 : 4 : 5 : nil)
    assert $ map _.right (wilt predE nil) == Identity nil

    assert $ wither predM testlist == Identity (60 : 70 : 80 : 90 : nil)
    assert $ wither predM nil == Identity nil

   where
    pred x = if x > 5 then Just (x * 10) else Nothing
    predM x = if x > 5 then Identity (Just (x * 10)) else Identity Nothing
    predE x = if x > 5 then Identity (Right (x * 10)) else Identity (Left x)

    testEqNoYes :: ∀ a. (Ord a) => { no :: a, yes :: a } -> { no :: a, yes :: a } -> Boolean
    testEqNoYes { no: n1, yes: y1 } { no: n2, yes: y2 } = n1 == n2 && y1 == y2

step :: Int -> Maybe (Tuple Int Int)
step 6 = Nothing
step n = Just (Tuple n (n + 1))

odd :: Int -> Boolean
odd n = n `mod` 2 /= zero

doubleAndOrig :: Int -> List Int
doubleAndOrig x = x * 2 : x : nil
