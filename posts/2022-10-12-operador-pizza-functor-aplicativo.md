---
title: 'El operador pizza y el functor aplicativo'
date: 2022-10-12
tags:
  informática
  programación
  elm
---
Elm tiene un operador, `|>`, que permite escribir de una forma distinta una expresión que llama a una función. Si de normal escribiríamos llamar a una función f con los parámetros a, b y c como `f a b c`, también podemos escribirlo como `c |> f a b`. El operador simplemente reescribe la expresión para que c sea el último parámetro de la llamada a la función. Este operador, conocido cómicamente como el operador pizza debido a su forma triangular, también existe en otros lenguajes de programación, y aunque dependiendo del lenguaje su significado es ligeramente distinto, sobre todo alterando si la expresión a la izquierda se pasa como el último parámetro de la función o como el primero según lo que sea más idiomático en ese lenguaje, hace más o menos lo mismo en todos.

Una propiedad muy interesante de este operador se puede apreciar en el uso que le da Richard Feldman en la biblioteca [elm-json-decode-pipeline](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest/). Esta biblioteca hace un uso bastante creativo del operador pizza para lograr emular un [functor aplicativo](/posts/intuicion-functor-aplicativo). La biblioteca permite escribir una función para leer una estructura a partir de un objeto de json, con un patrón muy similar a llamar a una función de varios parámetros con un functor aplicativo. Veamos el ejemplo que dan en la página.

```Elm
type alias User =
  { id : Int
  , email : Maybe String
  , name : String
  , percentExcited : Float
  }

userDecoder : Decoder User
userDecoder =
  Decode.succeed User
    |> required "id" Decode.int
    |> required "email" (Decode.nullable Decode.string) -- `null` decodes to `Nothing`
    |> optional "name" Decode.string "(fallback if name is `null` or not present)"
    |> hardcoded 1.0
```

El patrón que vemos es el mismo que con el functor aplicativo. `Decode.succeed` es pure para decodificadores de json en Elm, y se usa para elevar el constructor de `User` al tipo del functor. User es una función que coge cuatro parámetros: un `Int`, un `Maybe String`, una `String` y un `Float`, y vamos a llamarlo con cuatro valores de tipo `Decoder`, cada uno del tipo del parámetro en cuestión. `Decode.int` es de tipo `Decoder Int`, `Decode.nullable Decode.string` es de tipo `Decoder (Maybe String)` y `Decode.string` es de tipo `Decoder String`. De `hardcoded 1.0` hablamos ahora.

La magia sucede en las funciones `required`, `optional` y `hardcoded`. Lo que está haciendo el operador `|>` es invocar una de estas funciones con el constructor dentro de un `Decoder` y los parámetros a su derecha. Estas tres funciones, `required`, `optional` y `hardcoded`, lo que hacen en esencia es coger un `Decoder` de función y unos parámetros con los que construir otro, y devolver un nuevo `Decoder` con el resultado de haber aplicado a la función el contenido del parámetro a la derecha.

Tal vez el ejemplo se entienda mejor si lo reescribimos en términos de `custom`, que es otra función que también ofrece la biblioteca. El tipo de `custom` es este:

```Elm
required : Decoder a -> Decoder (a -> b) -> Decoder b
```

¿Suena conocido, verdad? Y la declaración de `userDecoder` del ejemplo anterior escrita únicamente en términos de `custom` quedaría algo así.

```Elm
userDecoder : Decoder User
userDecoder =
  Decode.succeed User
    |> custom (Decode.field "id" Decode.int)
    |> custom (Decode.field "email" (Decode.nullable Decode.string)) -- `null` decodes to `Nothing`
    |> custom (Decode.oneOf [Decode.field "name" Decode.string, Decode.succeed "(fallback if name is `null` or not present)"]
    |> custom (Decode.succeed 1.0)
```

`|> custom` es lo mismo que lo que Haskell llama `<*>`. En cada caso estamos cogiendo un `Decoder (a -> b)` y un `Decoder a` y devolviendo un `Decoder b`. Al final de la expresión se ha aplicado cuatro parámetros a un `Decoder` de una función que coge cuatro parámetros (`Decode.succeed User`), lo que nos deja con un `Decoder` del resultado.

Hasta ahora hemos aprendido que podemos emular el patrón de diseño del functor aplicativo sin tener que sacarnos un nuevo operador de la manga, simplemente con funciones normales y un poco de pizza. Esto es especialmente útil en Elm que, a diferencia de Haskell, no permite al programador crear nuevos operadores. Pero también es interesante más allá de eso. Vamos con lo realmente chulo.

Lo interesante de este patrón es que, a diferencia de con el functor aplicativo convencional, muy rara vez se usa `|> custom`. El patrón más común con un functor aplicativo en Haskell es crear expresiones donde se llama a una función con varios parámetros, concatenando las llamadas con `<*>`. Esto crea una mayor rigidez, ya que estamos limitados a una sola definición de `<*>` por tipo de functor. Aquí sin embargo la composición está definida en una función normal, y eso significa que si quisiéramos alterar la forma en la que sucede esa composición, tan sólo hace falta escribir una nueva función. También es posible escribir funciones que internamente llamen a `custom` pero le den una interfaz más fácil de usar y más legible. El primer ejemplo, con las llamadas a `required`, `optional` y `hardcoded`, es mucho más legible que el segundo, con las cuatro llamadas a `custom`. Esas tres funciones son muy simples. Aquí está la implementación.

```Elm
required : String -> Decoder a -> Decoder (a -> b) -> Decoder b
required name decoder = custom (Decode.field name decoder)

optional : String -> Decoder a -> a -> Decoder (a -> b) -> Decoder b
optional name decoder fallback = custom (Decode.oneOf [Decode.field name decoder, Decode.succeed fallback])

hardcoded : a -> Decoder (a -> b) -> Decoder b
hardcoded constant = custom (Decode.succeed constant)
```

Hacer que la composición esté definida en una función normal en lugar de un operador mágico hace que cualquiera pueda escribir otra función que modifique o matice el significado de esa composición, lo que permite al código ser más expresivo.

Por lo tanto, el operador pizza no sólo permite tener functores aplicativos a lenguajes que no pueden crear nuevos operadores, sino que encima estos son más flexibles y más legibles que los de Haskell, y eso usando únicamente funciones normales y corrientes. Bueno, y pizza.
