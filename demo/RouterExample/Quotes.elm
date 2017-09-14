module RouterExample.Quotes exposing (Quote, Model, init, get, next, defaultQuote, errorQuote)

import Array exposing (Array)
import Random


type alias Quote =
    { quoteText : String
    , quoteAuthor : String
    }


type alias Model =
    { quote : Quote
    , seed : Random.Seed
    }


init : Int -> Model
init i =
    next { quote = defaultQuote, seed = Random.initialSeed i }


get : Model -> Quote
get =
    .quote


next : Model -> Model
next model =
    let
        ( nextQuote, nextSeed ) =
            Random.step quote model.seed
    in
        { model | quote = nextQuote, seed = nextSeed }



-- PRIVATE FUNCTIONS


quote : Random.Generator Quote
quote =
    Random.int 0 maxQuoteIndex
        |> Random.map
            (\i -> Array.get i quoteArray |> Maybe.withDefault errorQuote)


maxQuoteIndex : Int
maxQuoteIndex =
    (Array.length quoteArray) - 1


defaultQuote : Quote
defaultQuote =
    { quoteText = "Genius is one percent inspiration and ninety-nine percent perspiration."
    , quoteAuthor = "Thomas Edison"
    }


errorQuote : Quote
errorQuote =
    { quoteText = "ERROR! One fails forward toward success."
    , quoteAuthor = "Charles Kettering"
    }


quoteArray : Array Quote
quoteArray =
    Array.fromList
        [ defaultQuote
        , { quoteText = "You can observe a lot just by watching."
          , quoteAuthor = "Yogi Berra"
          }
        , { quoteText = "A house divided against itself cannot stand."
          , quoteAuthor = "Abraham Lincoln"
          }
        , { quoteText = "Difficulties increase the nearer we get to the goal."
          , quoteAuthor = "Johann Wolfgang von Goethe"
          }
        , { quoteText = "Fate is in your hands and no one elses"
          , quoteAuthor = "Byron Pulsifer"
          }
        , { quoteText = "Be the chief but never the lord."
          , quoteAuthor = "Lao Tzu"
          }
        , { quoteText = "Nothing happens unless first we dream."
          , quoteAuthor = "Carl Sandburg"
          }
        , { quoteText = "Well begun is half done."
          , quoteAuthor = "Aristotle"
          }
        , { quoteText = "Life is a learning experience, only if you learn."
          , quoteAuthor = "Yogi Berra"
          }
        , { quoteText = "Self-complacency is fatal to progress."
          , quoteAuthor = "Margaret Sangster"
          }
        , { quoteText = "Peace comes from within. Do not seek it without."
          , quoteAuthor = "Buddha"
          }
        , { quoteText = "What you give is what you get."
          , quoteAuthor = "Byron Pulsifer"
          }
        ]
