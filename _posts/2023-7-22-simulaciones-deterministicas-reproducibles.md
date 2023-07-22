---
layout: post
title: Simulaciones determinísticas reproducibles y su aplicación al desarrollo de videojuegos
date: 2023-7-22
tags:
  informática
  programación
  videojuego
---
<p style='text-align: justify;'>Este texto expone una serie de técnicas e ideas que se pueden usar en el desarrollo de videojuegos para solucionar diferentes problemas. Aunque tengo experiencia usando simulaciones determinísticas reproducibles, no he implementado todas ellas y algunas están aquí en parte para dejar constancia de la idea, por si en el futuro escribo otro videojuego, para acordarme de ellas y probarlas.</p>

# ¿De qué estamos hablando?

<p style='text-align: justify;'>Lo primero de todo, necesitamos definir, para nuestro juego, qué significa una “partida” o “sesión de juego”. Podría ser jugar una partida propiamente dicha para un juego competitivo por partidas como <i>League of Legends</i>, jugar un nivel en algo como un juego de plataformas, una partida aleatoria en un roguelike, o el tiempo entre cargar un mundo y dejar de jugar en un juego de mundo abierto, por poner unos pocos ejemplos. El concepto es bastante transversal. El caso es que necesitamos definir qué es una sesión de juego para nuestro juego.</p>

<p style='text-align: justify;'>Una vez que tenemos esta definición, necesitamos definir dos cosas más.</p>

<p style='text-align: justify;'>Por un lado, tenemos que poder definir el conjunto de parámetros exacto con el que construir una partida, de forma que dados los mismos parámetros obtenemos la misma partida. Volviendo a los ejemplos anteriores, en el <i>LoL</i> esto serían los 10 personajes que integran la partida, el equipo y lado del mapa en el que juega cada uno, las maestrías y hechizos de invocador elegidos por cada jugador y decisiones que van a afectar al transcurso de la partida como los tipos de dragón. En <i>New Super Mario Bros</i> por ejemplo sería el nivel que se va a jugar, el estado inicial del jugador (pequeño, grande, flor de fuego, pingüino…), el objeto en la reserva, la cantidad de vidas que tiene… En <i>The binding of Isaac</i>, necesitaríamos el personaje elegido, la configuración de dificultad, la semilla que usar para generar el mapa aleatorio y la lista de objetos bloqueados y desbloqueados, entre otras cosas. Para un juego de mundo abierto podríamos necesitar todo el archivo de partida guardada para poder reconstruir una sesión idéntica. </p>

<p style='text-align: justify;'>Es importante definir todos los parámetros, incluso aquellos en los que de normal no pensamos. Los números aleatorios no salen de la nada, por ejemplo. Si un juego necesita números aleatorios, aunque sea para animar partículas, convertir golpes en críticos de vez en cuando o hacer a la IA más variada, la semilla que se usa para esta aleatoriedad es un parámetro con el que se construye la sesión de juego. Cualquier global mágica de la que se dependa y que no esté considerada como uno de estos parámetros rompe el sistema.</p>

<p style='text-align: justify;'>La segunda cosa que necesitamos es definir los parámetros de la función para, dado el estado del mundo en un momento en el tiempo, calcular el estado del mundo en el siguiente fotograma. Por lo general esto va consistir en el tiempo que ha pasado desde el último fotograma y los botones del mando o teclado que el jugador ha pulsado desde entonces. Para el servidor de un juego online no hay jugadores pulsando botones, pero sí todos los mensajes que llegan desde la red, de cada uno de los jugadores conectados.</p>

<p style='text-align: justify;'>Una vez que tenemos ambas cosas definidas, si guardamos en un archivo la información necesaria para construir una partida y para calcular cada fotograma durante toda la duración de la sesión de juego, podemos reconstruir esa partida con exactitud en el futuro. En este texto vamos a explorar diferentes aplicaciones de esta técnica.</p>

# ¿Pero no me voy a quedar sin memoria?

<p style='text-align: justify;'>Seguramente no.</p>

<p style='text-align: justify;'>A priori podría parecer que esto requiere archivos de terabytes de información para poder reproducir con exactitud una partida pasada, pero veremos que no es así. Saquemos números.</p>

<p style='text-align: justify;'>¿Qué información necesita un juego de un solo jugador, sin internet, para avanzar el estado del mundo un fotograma? El tiempo que ha pasado desde el anterior. Esto van a ser 4 bytes por lo general. Y los controles que ha podido hacer el jugador. Con un formato de codificación eficiente, de longitud variable, podemos estimar que el fotograma medio va a necesitar 2 bytes de encabezado, 8 bytes para los 2 joysticks del mando y unos 6 bytes para los posibles botones que el jugador pueda pulsar. En total unos 20 bytes por fotograma. Esto son 1200 bytes por segundo, 72.000 por minuto, 4.320.000 por hora. Es decir, 4,12 megabytes de memoria para guardar una hora de grabación.</p>

<p style='text-align: justify;'>Si el juego es muy simple y uno se quiere poner creativo se puede buscar hacer el formato más eficiente. Por ejemplo, en <i>World of Traps: Speedrun Edition</i> el juego estaba bloqueado a 60 fotogramas por segundo, de forma que sabíamos que el tiempo entre fotogramas era siempre 0,0167 segundos, y sólo tenía 4 inputs, de forma que podíamos representarlo con 4 bits. Esto significa que se puede guardar una hora de grabación de <i>World of Traps</i> en poco más de 105 kilobytes de memoria.</p>

<p style='text-align: justify;'>Dado lo grandes que son los discos duros y la memoria RAM hoy en día, y que para la mayoría de usos de los que vamos a hablar no necesitamos grabaciones tan largas y que incluso una hora es muchísimo, estos números están totalmente dentro de lo que nos podemos permitir.</p>

<p style='text-align: justify;'>Por supuesto, a esto hay que añadirle también un encabezado con la información para poder construir la partida, pero sólo necesitamos uno de esos, así que, aunque sea tirando a grande, nos da bastante igual. Unos pocos kilobytes de información en parámetros para construir una partida es una barbaridad de complejidad y de sobra para la mayoría de juegos, mientras que en el disco duro ese tamaño es aproximadamente equivalente a 0.</p>

<p style='text-align: justify;'>Ahora, hablemos sobre qué podemos hacer con esto.</p>

# Reproducciones

<p style='text-align: justify;'>El uso más obvio, y el que usábamos en <i>World of Traps</i>, es poder reproducir partidas pasadas. Mientras que el jugador juega vamos grabando todos los controles que pulsa, y al final de la partida le dejamos guardar una reproducción de lo que ha jugado para que pueda verla en el futuro.</p>

<p style='text-align: justify;'>Programar reproducciones para nuestro juego es muy fácil si diseñamos el código desde el principio de forma que el estado del mundo sea fácil de reconstruir y de actualizar de acuerdo a los parámetros que queramos, vengan estos del jugador o de un archivo. Es también algo chulo que tener en según qué juegos. Hay jugadores a los que les gusta, cuando hacen una jugada espectacular, logran una victoria inesperada o simplemente tienen una partida especialmente bonita, guardársela para el recuerdo. Esto es bastante fácil de programar en la práctica.</p>

# Reproducir bugs y crashes

<p style='text-align: justify;'>Si podemos reproducir aquel golazo espectacular que marcó Fulanito en Rocket League, también podemos reproducir esa vez en la que un QA rompió la simulación física y salió volando por encima de los límites del nivel. Tener la posibilidad de extraer fácilmente una reproducción de una sesión de juego, que al ser reproducida va a replicar fielmente la ejecución del código original, puede ser extremadamente útil durante el desarrollo. Los QAs podrían adjuntar como información extra de sus informes de bugs una reproducción que automáticamente lleve al juego a esa situación, lo que facilita mucho que luego un programador llegue a esa misma situación en el debugger y pueda examinar lo que está sucediendo línea a línea y variable a variable.</p>

<p style='text-align: justify;'>Con un poco de trabajo, se puede hacer que el programa al crashear automáticamente escriba la reproducción antes de morir, lo que genera una forma automatizada de reproducir el crash.</p>

<p style='text-align: justify;'>Si vamos a hacer esto, es buena idea que la reproducción incluya la versión del programa en la que se ha jugado, para evitar jugar reproducciones pasadas en las que los bugs ya han sido arreglados, o que hacen cosas que ya no tienen sentido porque el juego ha cambiado y esos controles ya no significan lo mismo.</p>

# Tests de regresión para crashes pasados

<p style='text-align: justify;'>Pongámonos en situación. Se ha reportado un crash en el juego, se nos hace llegar la reproducción, se prueba, se encuentra el problema y se arregla. Sería tentador ahora tirar esa reproducción a la basura. Ya ha hecho su trabajo. Ahora bien, en vez de eso, se podría guardar y seguir ejecutándola de vez en cuando en el futuro para asegurarnos de que el crash no ha vuelto.</p>

<p style='text-align: justify;'>Incluso, se podría hacer un sistema automatizado que abre el juego, reproduce estas grabaciones pasadas que solían romperse, y se asegura de que el arreglo sigue en pie. A la larga, conforme se vayan acumulando unas cuantas reproducciones, podemos construir una biblioteca considerable de grabaciones realistas que en algún momento han roto el juego, y que si se siguen ejecutando con regularidad pueden ser capaces de encontrar en el futuro crashes nuevos o regresiones de crashes viejos arreglados que se han vuelto a romper.</p>

# Reaccionar a crashes y recuperar la partida del jugador

<p style='text-align: justify;'>Idealmente, la versión final de un juego nunca debería tener un crash cuando un jugador lo está jugando en su casa. Pero a veces sucede. Y esas veces son muy molestas. Ahora bien, si mientras el jugador juega vamos guardando en memoria los datos necesarios para reconstruir su partida, si resultara que el programa peta, sería posible, por ejemplo, coger la excepción en lugar de dejar que el programa se cierre, descartar los últimos 15 o 20 segundos de grabación, reproducir la partida hasta ese punto para reconstruir el estado del mundo poco antes de que sucediera el error, y dejar que el jugador siga jugando.</p>

<p style='text-align: justify;'>Para poder hacer esto es importante que el estado del mundo se pueda actualizar sin dibujar imágenes a la pantalla, y a ser posible más rápido que a la velocidad a la que se juega. Si tenemos una partida de media hora que reconstruir, no queremos tardar media hora en reconstruirla.</p>

<p style='text-align: justify;'>También es cierto que esta técnica es más fácil de implementar en lenguajes de programación que tratan los crashes como excepciones que se propagan por la pila de llamadas, como Java, C#, Python o Rust, en lugar de lenguajes que abortan inmediatamente el programa ante una situación así, como C o C++, pero también se puede hacer en éstos últimos con un poco más de esfuerzo.</p>

# Bonus: reaccionar a crashes en juegos online

<p style='text-align: justify;'>Esta técnica está derivada de la anterior y trasladada a juegos online. Es la única que no requiere de guardar reproducciones, pero la incluyo por su parecido con la anterior. Si el lector ha jugado al <i>LoL</i>, seguramente habrá visto alguna vez esta ventana.</p>

![Ventana de error que sale cuando el videojuego League of Legends tiene un crash](https://raw.githubusercontent.com/asielorz/blog/master/images/bug-splat.png)

<p style='text-align: justify;'>Es muy frustrante cuando un juego multijugador competitivo en tiempo real peta en mitad de una partida porque ese minuto y medio o dos minutos que se tarda en volver a lanzar el juego y pasar por la pantalla de carga dan una ventaja injusta al rival. ¿Y si no tuviera que ser así? Sabemos que un cliente puede pedir al servidor que le envíe todo el estado del mundo, porque es posible conectarse a una partida a la mitad. Entonces, en lugar de cerrar el proceso, un juego online con el código diseñado para esto podría hipotéticamente descartar todo el estado del mundo, que sabemos que es erróneo, y pedir al servidor que se lo vuelva a enviar. Nos saltamos el tener que volver a abrir el juego, nos saltamos la pantalla de carga, esos 2 minutos se convierten seguramente en 5 o 10 segundos. Sigue siendo injusto y frustrante, pero bastante menos.</p>

# Conclusiones

<p style='text-align: justify;'>Ser capaces de almacenar en un formato compacto una sesión de juego de un videojuego que estamos desarrollando puede tener numerosos usos, tanto durante el desarrollo como en el producto terminado.</p>

<p style='text-align: justify;'>Poder implementar esta técnica requiere diseñar la arquitectura del proyecto de forma que es fácil construir una partida a partir de los parámetros que la configuran y reproducir sesiones de juego pasadas sin necesidad de que nadie pulse botones en un mando, leyendo los controles desde un archivo. Esto incluye un par de pasos extra que pueden ser molestos a priori, como asegurarse de que no se usan globales mágicas. También es útil tener en cuenta consideraciones adicionales, como diseñar el código de forma que se pueda actualizar el mundo sin tener que dibujar a la pantalla, que pueden combinar bien con algunas de las técnicas descritas arriba.</p>

<p style='text-align: justify;'>Una vez hecho el trabajo inicial, el haber guardado estos datos permite implementar multitud de herramientas valiosas. Este texto incluye solamente una breve selección, pero seguro que cada uno es capaz de encontrar varias más.</p>
