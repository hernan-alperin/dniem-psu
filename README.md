# Borrador DNMIE – Construcción de PSU para el Nuevo Marco de Referencia de Muestreo

En esta nota se comentan primera y brevemente los diversos métodos empleados 
para el armado de PSU para el nuevo marco, junto con sus ventajas y desventajas. 
Luego se muestra una aplicación sobre los radios del Censo 2010 de la localidad de Rosario.

## MaxP

### Duque, J. C., Anselin, L., & Rey, S. J. (2012). 
The max‐p‐regions problem.

El método “max p” busca el número máximo de regiones que maximizan 
la homogeneidad en variables objetivo, respetando un tamaño mínimo 
de las regiones fijado como parámetro. 
Tiene la ventaja de que el número de regiones es calculado por el algoritmo, 
garantiza contigüidad y respeta un tamaño mínimo de las regiones. 
Tiene las desventajas de que no se puede fijar un tamaño máximo de las regiones 
y de que busca crear regiones homogéneas cuando nuestro objetivo es 
crear regiones heterogéneas

## Programa lineal

### Hess, S. W., Weaver, J. B., Siegfeldt, H. J., Whelan, J. N., & Zitlau, P. A. (1965). Nonpartisan political redistricting by computer. 

El método de “distritos iguales” busca dividir distritos en K regiones, 
tratando de que éstas sean lo más compactas posible. Se basa en un programa lineal 
que intenta minimizar la compacidad de las regiones, de tal forma que respeten 
límites de tamaño preestablecidos. 
Tiene la ventaja de respetar los límites poblacionales fijados, 
pero no garantiza contigüidad de las regiones formadas y 
requiere del número de regiones a crear como parámetro.

Una variante utilizada para crear clusters fue una combinación de “max-p” 
con el algoritmo de “distritos iguales” (UltraClusters). 
Se le pidió al maxp que homogeneizara solo la variable de tamaño (viviendas habitadas) y 
un tamaño mínimo de regiones igual al tamaño objetivo. 
Los clusters “grandes” resultantes de max-p (de aproximadamente el doble del tamaño objetivo) 
fueron entregados al programa lineal para que los rompiera en dos mitades de tamaño similar. 
La salida de este método entonces son los clusters formados por max p y 
los clusters de maxp que pasaron por el programa lineal, 
lo que mejora la uniformidad del tamaño de estos últimos, 
pero rompe la contigüidad brindada por el maxpl.



