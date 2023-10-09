---
layout: post
title: Muchos programadores nunca escriben abstracciones
date: 2023-3-1
tags:
  informática
  programación
---
> "El propósito de la abstracción no es ser impreciso, sino crear un nuevo nivel semántico en el que uno puede ser absolutamente preciso."
> 
> -Edsger W. Dijkstra

La abstracción es fundamental para la programación. Es lo que permite escribir y mantener programas complejos sin que se desmoronen. Cada programa está construido sobre múltiples capas de abstracción. El conjunto de instrucciones del procesador abstrae los circuitos eléctricos que hacen los cálculos. El compilador traduce un lenguaje pensado para humanos a estas instrucciones de procesador. El sistema operativo abstrae la interacción con el hardware a una serie de interfaces comunes y más simples. El propio programa se compone de capas de abstracción donde cada una construye sobre la anterior. Bibliotecas que implementan las estructuras de datos fundamentales y la gestión de la memoria, sobre ellas estructuras de datos más complejas, redes, organización de los archivos que el programa lee y escribe, formatos de intercambio de datos, algoritmos y modelos propios del campo al que pertenezca el programa… Suele ser común que un programa se escriba sobre bibliotecas escritas por otros que implementan muchas de estas abstracciones. Los lenguajes de programación suelen tener una “biblioteca estándar” con las abstracciones más fundamentales, como estructuras de datos, y la mayoría de programas hoy en día suele depender también de otras bibliotecas para abstracciones más específicas de su campo.

Sin abstracciones sería casi imposible escribir programas grandes. Y no me refiero sólo a sin un compilador o sin un sistema operativo. Sin organizar el código de un programa en capas donde cada una construye sobre las demás y se encarga de solucionar un problema, es imposible crecer el programa a partir de cierto punto sin que colapse bajo su propio peso. Como decía Dijkstra en la cita que abre este texto, las abstracciones permiten escribir cada parte de un programa en el lenguaje de su campo, sin tener que preocuparse por los pormenores de otros campos a la vez. Por ejemplo, las abstracciones permiten escribir la inteligencia artificial de un videojuego hablando sólo el lenguaje de la inteligencia artificial, sin tener que a la vez preocuparse por temas como gestión de memoria, cálculos aritméticos y geométricos, algoritmos de grafos y demás temas que, aunque necesarios para la inteligencia artificial, quedan abstraídos por una capa inferior que se encarga de los detalles y ofrece una interfaz declarativa.

La mayoría de programadores parece entender este hecho. Esto se puede ver en que la mayoría de programas están construidos sobre bibliotecas que proveen abstracciones útiles para el programa. Además, es común que estos programadores sientan un interés por aprender sobre estas abstracciones, cómo usarlas correctamente y qué más herramientas tienen a su disposición que les puedan facilitar el trabajo. Cuando un programador se encuentra una abstracción bien diseñada, por lo general es capaz de usarla correctamente y apreciar el valor que aporta.

Sin embargo, esto no parece traducirse en una capacidad ni un interés igual por escribir nuevas abstracciones. Lo cierto es que en muchos programas todo el código está escrito a exactamente el mismo nivel de abstracción, que es exactamente una capa por encima de las bibliotecas que están usando. El código escrito por los programadores que escriben ese programa no está estructurado en capas, sino que es todo él una sola capa por encima de sus dependencias. Para muchos programadores sólo hay dos tipos de código, “el mío” y “el de otros”. El que puedo modificar y el que no puedo modificar.

Visualicémoslo con un ejemplo. Supongamos dos funciones, A y B, donde B llama a A.

```cpp
void A()
{
	// Cuerpo de A
}

void B()
{
	// Cosas que hace B antes de A.
	A();
	// Cosas que hace B después de A.
}
```

Supongamos que necesitamos que cierta operación, llamémosla C, suceda justo antes de A. Para muchos programadores, la pregunta de si C debería ir dentro de B, antes de la llamada a A, o dentro de A, justo al principio, es absurda. Son lo mismo. El ordenador va a hacer lo mismo. Así que da igual si se pone en un lado o en el otro, y se terminará poniendo en cualquier lado. En el archivo que resulta que esté abierto cuando el programador se da cuenta de que necesita una llamada a C. Y no se le dará dos vueltas a la pregunta. Ni siquiera hay pregunta.

```cpp
void A()
{
	// ¿C() va aquí?
	// Cuerpo de A
}

void B()
{
	// Cosas que hace B antes de A.
	// ¿O C() va aquí?
	A();
	// Cosas que hace B después de A.
}
```

En cierta medida, esta forma de pensar es razonable. Efectivamente, el programa va a hacer lo mismo. Las instrucciones que va a ejecutar el programa son las mismas. El comportamiento observable para el usuario va a ser idéntico. ¿Para qué darle más vueltas?
El problema que subyace a esta situación es una total ausencia de significado en el código. Al menos de significado intencional. Estas dos funciones no significan nada más que la sucesión exacta de operaciones que llevan a cabo. Por eso da igual si se cambia una o la otra. El significado de ninguna va a alterarse de forma relevante, porque no tienen. Incluso su separación es arbitraria. ¿Qué nos impide coger todo el código de A, meterlo dentro de B y borrar A? Por supuesto, esta pregunta tiene implicaciones muy reales a la hora de mantener, reusar, modificar, arreglar u optimizar el código. Por eso le estamos dando más vueltas.

Como decía Dijkstra, las abstracciones tienen que ver con el significado. El propósito de la abstracción es crear un nuevo nivel semántico. Es coger una sucesión de operaciones y darle un significado a hacer esas operaciones en concreto en ese orden. O coger una colección de datos y darle un significado a su agrupación. No son dos números y un puntero. Es un array dinámico. No es una comparación, y luego una suma, y luego copiar unos datos de aquí a allá, y a lo mejor una llamada a free, una multiplicación y una llamada a malloc. Es insertar un elemento al final del array dinámico. Y al dar nombre y estructura a estos datos y operaciones se está dando también una serie de garantías, como que al insertar un elemento al final de un array el tamaño del array siempre aumenta en 1, o que los demás elementos no cambian, o que el elemento al final del array va a ser igual al que hemos insertado. Podemos razonar sobre estas operaciones y garantías y escribir código sin entender los pormenores de su implementación, pensando solamente en su significado.

Por desgracia, el código de muchos programas no es así. Depende de código que sí es así, pero no lo imita. Y es una lástima. Por un lado, porque este código es muy difícil y costoso de mantener. Cuando el significado de una función o una clase no está claro, es difícil dilucidar qué código nuevo debería ir dentro, y más importante, qué código no debería ir dentro. Así que sigue absorbiendo más y más comportamiento hasta convertirse en un amasijo inmantenible. Cómo dice Tony Van Eerd, las clases están hechas de velcro.

Y por otro lado porque queda claro que simplemente la exposición a buenos ejemplos no es suficiente para aprender o para querer imitarlos. Las buenas abstracciones son invisibles. Usarlas no lleva un esfuerzo. No se rompen. No dan problemas. No hay que pensar sobre ellas. Lo que significa que, por desgracia, no reciben mucha atención. Por poner un ejemplo trivial, las abstracciones de memoria como `std::vector` son innegablemente esenciales. Han ahorrado a la larga cientos de horas. Hacen que clases enteras de errores no puedan existir. Y sin embargo cada vez estoy más convencido de que si no vinieran ya hechas muchos programadores seguirían haciendo malloc y free a mano en el día a día. No por la pereza o la dificultad de implementar algo así, el alumno medio de segundo de carrera puede hacer una implementación mediocre de las estructuras de datos más básicas, sino porque ni se les pasaría por la cabeza la posibilidad.

Otro ejemplo lo veo en el gameplay ability system (GAS) desarrollado por Epic Games para Unreal Engine. El gameplay ability system es una pieza de ingeniería impresionante. Abstrae las reglas de un juego de rol con personajes que tienen habilidades como puede ser *League of Legends* o *World of Warcraft* y permite a los usuarios desarrollar sus propias habilidades, efectos, recursos, variables y fórmulas para modificar estas variables. Funciona a través de internet y sincroniza estas habilidades y efectos de forma que tiene sentido dentro del sistema. El GAS debería ser una biblioteca inspiradora. Ha conseguido abstraer las reglas del *LoL*, sistematizando aspectos como el uso de recursos, el tiempo de recarga, la disponibilidad o no de las habilidades en función de estados pasajeros del personaje o la sincronización por internet de forma que cada habilidad individualmente no tiene que preocuparse por nada de esto y puede simplemente centrarse en su lógica. La primera pregunta que debería suscitar el GAS es, ¿si se ha podido hacer esto para las reglas del *LoL*, para qué más juegos se puede hacer también? ¿De qué forma puedo abstraer las reglas de mi juego a un sistema que hable el lenguaje de mi juego, el de mis diseñadores, y me permita extender esas reglas hablando ese lenguaje? ¿Cómo sería “el GAS de mi juego”? Sin embargo, la pregunta que más comúnmente parece suscitar el GAS en programadores de videojuegos es ¿de qué forma puedo martillear las reglas del *LoL* para que mi juego encaje en ellas? Y sí, el GAS es muy potente, y puede representar cualquier juego. También lo es la cinta de Turing, y no escribimos juegos en Brainfuck. Y sí, entre hacer una chapuza de código espagueti y usar el GAS para un juego para el que no termina de encajar, usar el GAS es marginalmente mejor. Pero esa es una falsa dicotomía, en la que uno está atrapado cuando escribir abstracciones es algo que solamente hacen los demás.

No sé muy bien cómo terminar este texto. No tengo una solución mágica. No sé cuál es la razón por la que una porción significativa de los profesionales de esta disciplina puede pasarse años programando sin dividir su código en diferentes niveles de abstracción. Intuyo que es una habilidad que se aprende y se entrena, pero no sé cuál es el primer paso para empezar, ni cómo hacer la explicación accesible para mucha gente a la vez.

Acepto sugerencias.
