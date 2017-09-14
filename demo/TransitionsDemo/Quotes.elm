module TransitionsDemo.Quotes exposing (Quote, Model, init, get, next, defaultQuote, errorQuote)

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
        , { quoteText = "We can only learn to love by loving."
          , quoteAuthor = "Iris Murdoch"
          }
        , { quoteText = "Life is change. Growth is optional. Choose wisely."
          , quoteAuthor = "Karen Clark"
          }
        , { quoteText = "You'll see it when you believe it."
          , quoteAuthor = "Wayne Dyer"
          }
        , { quoteText = "Today is the tomorrow we worried about yesterday."
          , quoteAuthor = "Anonymous"
          }
        , { quoteText = "It's easier to see the mistakes on someone else's paper."
          , quoteAuthor = "Anonymous"
          }
        , { quoteText = "Every man dies. Not every man really lives."
          , quoteAuthor = "Anonymous"
          }
        , { quoteText = "To lead people walk behind them."
          , quoteAuthor = "Lao Tzu"
          }
        , { quoteText = "Having nothing, nothing can he lose."
          , quoteAuthor = "William Shakespeare"
          }
        , { quoteText = "Trouble is only opportunity in work clothes."
          , quoteAuthor = "Henry J. Kaiser"
          }
        , { quoteText = "A rolling stone gathers no moss."
          , quoteAuthor = "Publilius Syrus"
          }
        , { quoteText = "Ideas are the beginning points of all fortunes."
          , quoteAuthor = "Napoleon Hill"
          }
        , { quoteText = "Everything in life is luck."
          , quoteAuthor = "Donald Trump"
          }
        , { quoteText = "Doing nothing is better than being busy doing nothing."
          , quoteAuthor = "Lao Tzu"
          }
        , { quoteText = "Trust yourself. You know more than you think you do."
          , quoteAuthor = "Benjamin Spock"
          }
        , { quoteText = "Study the past, if you would divine the future."
          , quoteAuthor = "Confucius"
          }
        , { quoteText = "The day is already blessed, find peace within it."
          , quoteAuthor = "Anonymous"
          }
        , { quoteText = "From error to error one discovers the entire truth."
          , quoteAuthor = "Sigmund Freud"
          }
        , { quoteText = "Well done is better than well said."
          , quoteAuthor = "Benjamin Franklin"
          }
        , { quoteText = "Bite off more than you can chew, then chew it."
          , quoteAuthor = "Ella Williams"
          }
        , { quoteText = "Work out your own salvation. Do not depend on others."
          , quoteAuthor = "Buddha"
          }
        , { quoteText = "One today is worth two tomorrows."
          , quoteAuthor = "Benjamin Franklin"
          }
        , { quoteText = "Once you choose hope, anythings possible."
          , quoteAuthor = "Christopher Reeve"
          }
        , { quoteText = "God always takes the simplest way."
          , quoteAuthor = "Albert Einstein"
          }
        , { quoteText = "One fails forward toward success."
          , quoteAuthor = "Charles Kettering"
          }
        , { quoteText = "From small beginnings come great things."
          , quoteAuthor = "Anonymous"
          }
        , { quoteText = "Learning is a treasure that will follow its owner everywhere"
          , quoteAuthor = "Chinese proverb"
          }
        , { quoteText = "Be as you wish to seem."
          , quoteAuthor = "Socrates"
          }
        , { quoteText = "The world is always in movement."
          , quoteAuthor = "V. Naipaul"
          }
        , { quoteText = "Never mistake activity for achievement."
          , quoteAuthor = "John Wooden"
          }
        , { quoteText = "What worries you masters you."
          , quoteAuthor = "Haddon Robinson"
          }
        , { quoteText = "One faces the future with ones past."
          , quoteAuthor = "Pearl Buck"
          }
        , { quoteText = "Goals are the fuel in the furnace of achievement."
          , quoteAuthor = "Brian Tracy"
          }
        , { quoteText = "Who sows virtue reaps honour."
          , quoteAuthor = "Leonardo da Vinci"
          }
        , { quoteText = "Be kind whenever possible. It is always possible."
          , quoteAuthor = "Dalai Lama"
          }
        , { quoteText = "Talk doesn't cook rice."
          , quoteAuthor = "Chinese proverb"
          }
        , { quoteText = "He is able who thinks he is able."
          , quoteAuthor = "Buddha"
          }
        , { quoteText = "Be as you wish to seem."
          , quoteAuthor = "Socrates"
          }
        , { quoteText = "A goal without a plan is just a wish."
          , quoteAuthor = "Larry Elder"
          }
        , { quoteText = "To succeed, we must first believe that we can."
          , quoteAuthor = "Michael Korda"
          }
        , { quoteText = "Learn from yesterday, live for today, hope for tomorrow."
          , quoteAuthor = "Albert Einstein"
          }
        , { quoteText = "A weed is no more than a flower in disguise."
          , quoteAuthor = "James Lowell"
          }
        , { quoteText = "Do, or do not. There is no try."
          , quoteAuthor = "Yoda"
          }
        , { quoteText = "All serious daring starts from within."
          , quoteAuthor = "Harriet Beecher Stowe"
          }
        , { quoteText = "The best teacher is experience learned from failures."
          , quoteAuthor = "Byron Pulsifer"
          }
        , { quoteText = "Think how hard physics would be if particles could think."
          , quoteAuthor = "Murray Gell-Mann"
          }
        , { quoteText = "Love is the flower you've got to let grow."
          , quoteAuthor = "John Lennon"
          }
        , { quoteText = "Don't wait. The time will never be just right."
          , quoteAuthor = "Napoleon Hill"
          }
        , { quoteText = "One fails forward toward success."
          , quoteAuthor = "Charles Kettering"
          }
        , { quoteText = "Time is the wisest counsellor of all."
          , quoteAuthor = "Pericles"
          }
        , { quoteText = "You give before you get."
          , quoteAuthor = "Napoleon Hill"
          }
        , { quoteText = "Wisdom begins in wonder."
          , quoteAuthor = "Socrates"
          }
        , { quoteText = "Without courage, wisdom bears no fruit."
          , quoteAuthor = "Baltasar Gracian"
          }
        , { quoteText = "Change in all things is sweet."
          , quoteAuthor = "Aristotle"
          }
        , { quoteText = "What you fear is that which requires action to overcome."
          , quoteAuthor = "Byron Pulsifer"
          }
        , { quoteText = "The best teacher is experience learned from failures."
          , quoteAuthor = "Byron Pulsifer"
          }
        , { quoteText = "When performance exceeds ambition, the overlap is called success."
          , quoteAuthor = "Cullen Hightower"
          }
        , { quoteText = "When deeds speak, words are nothing."
          , quoteAuthor = "African proverb"
          }
        , { quoteText = "Real magic in relationships means an absence of judgement of others."
          , quoteAuthor = "Wayne Dyer"
          }
        , { quoteText = "When performance exceeds ambition, the overlap is called success."
          , quoteAuthor = "Cullen Hightower"
          }
        , { quoteText = "I never think of the future. It comes soon enough."
          , quoteAuthor = "Albert Einstein"
          }
        , { quoteText = "Skill to do comes of doing."
          , quoteAuthor = "Ralph Emerson"
          }
        , { quoteText = "Wisdom is the supreme part of happiness."
          , quoteAuthor = "Sophocles"
          }
        , { quoteText = "I believe that every person is born with talent."
          , quoteAuthor = "Maya Angelou"
          }
        , { quoteText = "Important principles may, and must, be inflexible."
          , quoteAuthor = "Abraham Lincoln"
          }
        , { quoteText = "The undertaking of a new action brings new strength."
          , quoteAuthor = "Richard Evans"
          }
        , { quoteText = "I believe that every person is born with talent."
          , quoteAuthor = "Maya Angelou"
          }
        , { quoteText = "The years teach much which the days never know."
          , quoteAuthor = "Ralph Emerson"
          }
        , { quoteText = "Our distrust is very expensive."
          , quoteAuthor = "Ralph Emerson"
          }
        , { quoteText = "All know the way; few actually walk it."
          , quoteAuthor = "Bodhidharma"
          }
        , { quoteText = "Great talent finds happiness in execution."
          , quoteAuthor = "Johann Wolfgang von Goethe"
          }
        , { quoteText = "Faith in oneself is the best and safest course."
          , quoteAuthor = "Michelangelo"
          }
        , { quoteText = "Courage is going from failure to failure without losing enthusiasm."
          , quoteAuthor = "Winston Churchill"
          }
        , { quoteText = "The two most powerful warriors are patience and time."
          , quoteAuthor = "Leo Tolstoy"
          }
        , { quoteText = "Anticipate the difficult by managing the easy."
          , quoteAuthor = "Lao Tzu"
          }
        , { quoteText = "Those who are free of resentful thoughts surely find peace."
          , quoteAuthor = "Buddha"
          }
        , { quoteText = "Talk doesn't cook rice."
          , quoteAuthor = "Chinese proverb"
          }
        , { quoteText = "A short saying often contains much wisdom."
          , quoteAuthor = "Sophocles"
          }
        , { quoteText = "The day is already blessed, find peace within it."
          , quoteAuthor = "Anonymous"
          }
        , { quoteText = "It takes both sunshine and rain to make a rainbow."
          , quoteAuthor = "Anonymous"
          }
        , { quoteText = "A beautiful thing is never perfect."
          , quoteAuthor = "Anonymous"
          }
        , { quoteText = "Only do what your heart tells you."
          , quoteAuthor = "Princess Diana"
          }
        , { quoteText = "Life is movement-we breathe, we eat, we walk, we move!"
          , quoteAuthor = "John Pierrakos"
          }
        , { quoteText = "No one can make you feel inferior without your consent."
          , quoteAuthor = "Eleanor Roosevelt"
          }
        , { quoteText = "One fails forward toward success."
          , quoteAuthor = "Charles Kettering"
          }
        , { quoteText = "Argue for your limitations, and sure enough they're yours."
          , quoteAuthor = "Richard Bach"
          }
        , { quoteText = "Luck is what happens when preparation meets opportunity."
          , quoteAuthor = "Seneca"
          }
        , { quoteText = "Victory belongs to the most persevering."
          , quoteAuthor = "Napoleon Bonaparte"
          }
        , { quoteText = "Once you choose hope, anythings possible."
          , quoteAuthor = "Christopher Reeve"
          }
        , { quoteText = "Love all, trust a few, do wrong to none."
          , quoteAuthor = "William Shakespeare"
          }
        ]
