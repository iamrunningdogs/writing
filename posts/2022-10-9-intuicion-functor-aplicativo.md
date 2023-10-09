---
layout: post
title: 'Desarrollar intuición para el functor aplicativo'
date: 2022-10-9
tags:
  informática
  programación
  haskell
---
Suele pasar con las estructuras algebraicas que, al ser muy abstractas, es difícil entender a partir de la definición qué idea representan. Al programar, no tener una intuición sobre las propiedades de una estructura algebraica puede hacer que no diseñemos nuestros tipos de datos para satisfacer sus axiomas, aun pudiendo, y no obtengamos el beneficio de todos los teoremas y algoritmos desarrollados para esta estructura. El functor aplicativo es una estructura de datos especialmente abstrusa y sorprendentemente útil una vez entendida. Este texto intentará ofrecer una intuición para entender cuál es el propósito detrás de esta estructura algebraica. No prometo que uno saldrá de haber leído este texto sabiendo lo que es un functor aplicativo, al fin y al cabo desarrollar intuición requiere tiempo y práctica y es difícil atajar, pero se hará lo que se pueda. Al menos, se intentará abstenerse de metáforas descabelladas y referencias a la gastronomía mexicana.

El functor aplicativo fue introducido, hasta donde tengo conocimiento, en un paper de 2008 titulado [*Applicative programming with effects*](http://www.staff.city.ac.uk/~ross/papers/Applicative.pdf). El paper es bastante confuso y es difícil extraer de él un propósito para lo que se está explicando. Sobre todo, es difícil entender, a partir de la definición, cuál es el problema que resuelve el functor aplicativo, y el paper no termina de dejar clara esta conexión. El functor aplicativo es una estructura de datos entre el functor y la mónada. Es decir, todos los functores aplicativos son functores, y todas las mónadas son functores aplicativos, pero no al revés.

Antes de comenzar con el functor aplicativo, repasemos el functor. Un functor es una estructura algebraica con una sola operación, llamada comúnmente `map` o `fmap`, y con la forma, dado un functor f:

```Haskell
fmap :: (a -> b) -> f a -> f b
```

Es decir, si tenemos un functor de As, y una función capaz de convertir As en Bs, podemos usar `fmap` para convertir el functor de As en un functor de Bs. Es valiosa aquí la intuición de Bartosz Milewski para entender los functores. Podemos pensar en un functor como su fuera un contenedor de As, que contiene en su interior varios valores de tipo A con alguna estructura. La función fmap transforma los valores contenidos en el functor, pero preserva la estructura. El ejemplo más común de functor suele ser la lista. Una lista contiene cero o más elementos de un mismo tipo en un cierto orden. Al llamar fmap sobre una lista con una función, se transforma cada elemento de la lista usando esa función y se obtiene como resultado una lista nueva, potencialmente de un tipo distinto, que contiene el resultado de transformar cada elemento de la primera lista con la función.

Fmap tiene sin embargo una limitación importante. Sólo funciona con funciones que cogen un solo parámetro. Sin embargo, se podría imaginar una situación en la que tenemos varios functores (varias listas, por ejemplo) y una función que coge varios parámetros, y que queramos llamar a esta función con estos functores. Fmap no nos va a ayudar en este caso. Y este es precisamente el propósito del functor aplicativo. Extender fmap a cualquier número de parámetros, de forma que dada una función que coge N parámetros y dados N functores donde el tipo del contenido de cada functor se corresponde con el tipo del parámetro, poder llamar a esa función con esos functores.

Para lograr eso, sobre la operación del functor, el functor aplicativo añade dos operaciones:

```Haskell
pure : a -> f a
(<*>) : f (a -> b) -> f a -> f b
```

`pure` es muy simple. Dado un elemento, construye un functor que contenga únicamente ese elemento. Muchos functores tienen esta operación. Por ejemplo, construir una lista de un solo elemento, un Maybe o Result lleno, o una función constante que siempre devuelve lo mismo independientemente del parámetro.

La segunda tiene más enjundia. Se parece mucho a fmap, pero hay una diferencia esencial. En lugar de coger una función como primer parámetro, la función viene también dentro de un functor. Como curiosidad, podemos definir fmap trivialmente en términos de estas dos funciones, demostrando así que todo functor aplicativo es también, por definición, un functor.

```Haskell
fmap t a = pure t <*> a
```

En un principio, es difícil ver cómo llegamos desde aquí a llamar a una función que coge por ejemplo tres parámetros dados tres functores. Esta es una función binaria igual que fmap, que de hecho se parece mucho a fmap. Y este es el clic. Vamos a llamar al operador `<*>` varias veces, no sólo una, en la misma expresión. Ésa es la razón por la que el operador pide que la función venga dentro de un functor. De esa forma, el resultado de una llamada a `<*>` puede servir como parámetro a otra llamada a `<*>`.

El otro elemento clave a tener en cuenta es el curry de las funciones. En Haskell y muchos otros lenguajes funcionales no existen las funciones que cogen más de un parámetro. Sólo hay funciones unarias. Cuando hablamos de una función que coge tres parámetros en Haskell, en realidad estamos hablando de una función unaria que devuelve otra función unaria que devuelve otra función unaria que devuelve el resultado final. La asociatividad, al escribir `f a b c`, es `(((f a) b) c)`. Hablamos de funciones que cogen varios parámetros por conveniencia y porque tiene más sentido en muchos contextos pensar en ellas así, pero es importante entender que por debajo todo son funciones unarias. ¿Dónde entra en juego esto con los functores aplicativos? Supongamos que tenemos una función `t : a -> b -> d`, y dos objetos, `fa` y `fb` de tipos `f a` y `f b` respectivamente. Queremos llamar a `t` con los contenidos de `fa` y `fb`.

Intentemos entender qué sucede en la siguiente expresión:

```Haskell
pure t <*> fa <*> fb
```

Comencemos por `pure t`. Simplemente estamos construyendo un functor que contiene solamente la función t. Este es un paso necesario para poder llamar por primera vez a `<*>`, pero no tiene especial significado ya que `pure t` es exactamente lo mismo que `t` para todos los functores.

Analicemos ahora la expresión `pure t <*> fa`.

En este caso estamos invocando `<*>` con dos parámetros de tipo `f (a -> b -> c)` y `f a` respectivamente. Aunque por lo general pensamos en una función de tipo `(a -> b -> c)` como una función que coge dos parámetros, de tipo `a` y `b`, y devuelve un valor de tipo `c`. Sin embargo, si recordamos el curry, podemos pensar también en ella como una función que coge un solo parámetro, de tipo `a`, y devuelve una nueva función de tipo `(b -> c)`. Al verlo así nos damos cuenta de que esta llamada a `<*>` va a llamar a `t` con un valor de tipo `a` para obtener una nueva función `(b -> c)` y a guardar el resultado en un functor, devolviendo así un resultado de tipo `f (b -> c)`.

De forma que en la segunda llamada a `<*>` el primer parámetro, que es el resultado de la expresión anterior, tiene el tipo `f (b -> c)`, mientras que el segundo parámetro tiene tipo `f b`. Siguiendo la definición podemos ver trivialmente que el resultado de esta expresión tiene tipo `f c`, que es lo que intentábamos obtener.

Esto no funciona sólo con dos parámetros. Es extensible a cualquier cantidad de parámetros. Podemos escribir una función que concatene tantas llamadas a `<*>` como haga falta para invocar la función con todos sus parámetros.

Por supuesto, al igual que `fmap` tiene una implementación distinta para cada tipo, lo mismo sucede con `<*>`. El ejemplo más simple es `Maybe`. `fmap` de `Maybe` es simple. Si el `Maybe` contiene un valor, transforma ese valor usando la función y devuelve un nuevo `Maybe` con el resultado de esa transformación. Si no, devuelve un `Maybe` vacío. La intuición con un functor aplicativo sería la misma, pero para una función con más parámetros. Si todos los `Maybes` tienen un valor, podemos llamar a la función y obtener un `Maybe` lleno con el resultado. Si al menos uno de los parámetros está vacío, el resultado será un `Maybe` vacío.

Recapitulando, en este texto hemos aprendido que el objetivo del functor aplicativo es extender `fmap` a funciones que cogen más de un parámetro. Para ello, usamos un operador un poco raro, `<*>`, que nos permite ir aplicando la función parcialmente parámetro a parámetro hasta que al final obtenemos el resultado.
