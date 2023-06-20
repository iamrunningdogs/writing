---
layout: post
title: La pureza de las funciones impuras
date: 2023-6-20
tags:
  programación
  informática
---
<p style='text-align: justify;'>Hemos hablado en el pasado de que <a href="https://asielorz.github.io/malloc-es-especial/">malloc es especial</a> y de que <a href="https://asielorz.github.io/concurrencia-estructurada-especial/">la concurrencia estructurada también es especial</a>. Hoy vamos a ver cómo lidian los lenguajes de programación funcionales con esta limitación y explorar el espacio de diseño para buscar alternativas.</p>

# Memoria

<p style='text-align: justify;'>Hay una unanimidad absoluta en que un lenguaje de programación funcional tiene que poder pedir memoria dinámica. El diseño suele ser bastante opaco. Las funciones para pedir memoria directamente no están expuestas al usuario. En su lugar, se ofrecen abstracciones que interactúan con la memoria de manera segura, garantizando la ausencia de efectos secundarios. Estas abstracciones suelen ser estructuras de datos como listas o árboles. </p>

<p style='text-align: justify;'>Haskell por ejemplo introduce memoria dinámica de manera invisible en partes del lenguaje como por ejemplo los tipos de dato recursivos, de forma que, si se define un tipo de dato de árbol de manera recursiva, como un nodo que contiene más nodos, eso implica implícitamente memoria dinámica.</p>

<p style='text-align: justify;'>Elm, al estar construido sobre JavaScript, usa los tipos de array y objeto de JavaScript que implícitamente usan memoria dinámica, y sólo tiene que preocuparse por ofrecer una interfaz segura.</p>

<p style='text-align: justify;'>Roc permite a la plataforma implementar una función llamada roc_alloc mediante la cual la plataforma puede controlar cómo se pide memoria en el programa, pero esta función es invisible para el código escrito en Roc, que en su lugar interactúa con estructuras de datos ya diseñadas para ser seguras, como en Haskell.</p>

# Paralelismo

<p style='text-align: justify;'>El paralelismo en Haskell es curioso. La función `par` permite paralelizar cualquier computación pura añadiéndola como tarea a la cola de tareas que trae integrada la biblioteca de Haskell. Intentar leer su valor antes de que termine de calcularse congela al hilo que está leyendo hasta que el valor esté disponible.</p>

<p style='text-align: justify;'>En Elm, al estar atado por el navegador, la posibilidad de paralelismo es escasa, y es la ofrecida por la interfaz del navegador. Las tareas que hacen IO se ejecutan en un segundo plano e interactúan con el programa mediante continuaciones monádicas y mensajes. Todo el código escrito por el programador se ejecuta secuencialmente.</p>

<p style='text-align: justify;'>En Roc el paralelismo es todavía una gran incertidumbre. La postura actual parece ser que la plataforma se encarga y Roc no sabe nada de paralelismo. Esto funciona muy bien para algunos programas, como por ejemplo servidores HTTP, que es para lo que el lenguaje está diseñado, pero me produce escepticismo cuanto más nos alejamos del ejemplo de diapositiva. En todo caso, una plataforma podría ofrecer posibilidad de ejecutar cosas en paralelo, pero eso requeriría usar tareas que son el mecanismo de efectos de Roc. Es decir, requeriría usar efectos para algo que es especial y podría hacerse sin ellos manteniendo el significado del programa, como hace Haskell por ejemplo.</p>

# Casos concretos en la biblioteca estándar

<p style='text-align: justify;'>En general, cuando hay un caso en el que se puede ofrecer una interfaz pura sobre una sucesión concreta de efectos secundarios, de forma que el significado del programa no queda alterado por esos efectos y podemos razonar sobre él como si no hubieran pasado, en los lenguajes funcionales existentes sucede una de dos cosas.</p>

<p style='text-align: justify;'>Una es que no se contemplen, y se obligue al usuario a usar el mecanismo del lenguaje de efectos secundarios (la mónada de IO en Haskell, Task en Elm y Roc) para escribir ese código, aunque en realidad sea puro. El problema principal de esta situación es que escribir ese código es mucho más tedioso de lo que debería, sobre todo si la función a cambiar está muy profunda en la pila de llamadas y hay que modificar numerosas capas de funciones para poder hacer el cambio.</p>

<p style='text-align: justify;'>Otra es que el lenguaje o su biblioteca incluyan sintaxis especial y código especial para permitir ese caso concreto, como es el pedir memoria en todos los lenguajes, o el paralelismo en Haskell. Esta forma funciona muy bien. La experiencia de usuario es todo lo buena que puede ser y el lenguaje o la biblioteca pueden encargarse de abstraer todas las partes feas o difíciles, pero es limitada, ya que no es extensible a nada que no haya sido contemplado por el diseño original. En Haskell, podemos ejecutar fácilmente código en otro hilo de ejecución, porque el lenguaje está diseñado para ello. Sin embargo, si queremos ejecutar el código en la tarjeta gráfica, o en una granja de servidores preparada para ello, la computación sería igual de pura, pero estamos obligados a recurrir a la mónada de IO.</p>

<p style='text-align: justify;'>Además, no se puede esperar que el propio lenguaje lo vaya a hacer todo. Va a haber extensiones que no van a querer implementar ya sea por falta de tiempo, por no estar de acuerdo o porque no se les ha ocurrido. Que sean los propios usuarios los que pueden desarrollar nuevas abstracciones mediante bibliotecas es necesario para un ecosistema sano de un lenguaje de programación.</p>

# Multitud de casos sin contemplar

<p style='text-align: justify;'>Este texto se ha centrado en la memoria y el paralelismo por ser las dos formas de efecto secundario de las que ya se había hablado antes aquí y las más contempladas por diferentes lenguajes de programación. Sin embargo, hay multitud en los que operaciones impuras no afectan al significado del programa. Ejemplos de esto pueden ser comprobar precondiciones escribir información de debug, recabar información y estadísticas sobre la velocidad del programa para poder optimizarlo…</p>

<p style='text-align: justify;'>Algunas de estas posibilidades están accesibles desde la parte pura en algunos lenguajes funcionales. Por ejemplo, Roc permite comprobar precondiciones con la palabra clave <code>expect</code> sin falta de usar <code>Task</code> para eso, y tiene una palabra clave crash para señalizar ramas inalcanzables en el flujo de control. Elm tiene la función <code>Debug.log</code> que permite escribir información de debug a la consola del navegador para inspeccionar el estado de un programa. Sin embargo, no todas están disponibles en todos los lenguajes, algunas no lo están en ninguno, y este intercambio de ideas es lento y parcial porque requiere tiempo y acuerdo de los equipos de desarrollo del propio lenguaje, que no siempre están por la labor.</p>

# Unsafe en Rust

<p style='text-align: justify;'>El lenguaje de programación Rust se enorgullece mucho de ser muy seguro. Tan rápido como C++, cero problemas de memoria y similares. Esta afirmación es mayormente cierta, con algunos peros muy interesantes, ya que son esos peros los que permiten que esta afirmación sea mayormente cierta.</p>

<p style='text-align: justify;'>La forma correcta de enunciarlo sería que el código escrito en Rust fuera de un bloque marcado con la palabra clave <code>unsafe</code> no puede tener errores de seguridad. Esto permite a un programa o una biblioteca escritos en Rust mover todo el código potencialmente inseguro a unas pocas funciones y comprobar rigurosamente que esas funciones son seguras bajo las invariantes del programa.</p>

<p style='text-align: justify;'>El significado de <code>unsafe</code> es muy interesante. Que un bloque esté marcado como <code>unsafe</code> no significa que sea inseguro. Significa que el compilador no es capaz de garantizar su seguridad, por lo que es responsabilidad de los humanos hacerlo. En otras palabras, la idea es que el 100% del código escrito en Rust sea seguro. La mayoría de las veces el compilador es capaz de demostrar que esto es verdad. Unas pocas veces esto no es posible, y les toca a los humanos hacer este trabajo de verificación. Una cosa que me gusta especialmente de la cultura de Rust es que todos los bloques <code>unsafe</code> deberían ir comentados con un comentario que explica por qué ese bloque sí es seguro a pesar de necesitar operaciones que no lo son.</p>

<p style='text-align: justify;'>El diseño de Rust, que permite a los programadores escribir código arbitrario usando herramientas inseguras y abstraerlo en interfaces seguras, compensado con una cultura que valora mucho la seguridad y el uso responsable de esta herramienta, es lo que permite que la frase de “tan rápido como C++, pero sin errores de seguridad” sea mayormente verdad.</p>

# Vuelta a la programación funcional

<p style='text-align: justify;'>Sería un experimento interesante en el campo del diseño de lenguajes de programación funcionales el permitir algo parecido a un bloque <code>impure</code>, análogo al bloque <code>unsafe</code> de Rust, que permita ejecutar código impuro dentro sin restricciones por parte del compilador, y haciendo responsable al programador de que efectivamente el conjunto de la abstracción que está escribiendo sea pura.</p>

<p style='text-align: justify;'>Esto permitiría a una biblioteca crear abstracciones que ahora mismo son imposibles de escribir como usuario de un lenguaje funcional, ofreciendo una experiencia de usuario tan buena como si fuera el propio compilador el que implementa la abstracción.</p>

<p style='text-align: justify;'>Es cierto que existe el riesgo de que se use mal, de que pasen a existir funciones que afirmen que son puras, pero no lo sean. Es un riesgo real. También lo existe en Rust y sin embargo no parece que el de las bibliotecas que no son seguras aunque afirmen serlo sea un problema grande a lo largo del ecosistema. Creo que este es el punto en el que entra más en juego el factor cultural estableciendo las expectativas de cómo tiene que ser el código escrito en el lenguaje.</p>

<p style='text-align: justify;'>Ser capaz de escribir código impuro en un lenguaje de programación puro puede ser, irónicamente, una buena idea. También puede que las posibilidades que ofrece de hacerlo mal sean demasiado grandes como para que pueda existir manteniéndose fiel a su propósito original, y que a la larga termine convirtiendo al lenguaje en otra cosa. Pero, desde luego, sería un experimento interesante que probar. Lo más parecido que se me ocurre en cuanto a diseño es <code>unsafe</code> en Rust, y a todas luces es una historia de éxito.</p>
