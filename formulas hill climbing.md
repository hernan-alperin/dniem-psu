La suma de cuadrados intracluster que utiliza el método “hill climbing” 
es la suma de cuadrados de muestreo PPS, a saber

```math
SCW = \sum_{i=1}^p{W_iSCW_i} 
```

donde

```math
SCW_i = \sum_{k=1}^L \frac{x_{\cdot\cdot}}{x_{\cdot k}}
        \sum_{j=1}^{N_k} \frac{x_{jk}}{x_{\cdot k}}
        \left( \frac{x_{\cdot k}}{x_{jk}} y_{ijk} - y_{i\cdot k} \right)^2
```

y 
$`p`$ es la cantidad de variables a considerar en la suma de cuadrados,
$`L`$, la cantidad de clusters a formar,
$`N_k`$, la cantidad de radios en el $k$-ésimo cluster,
$`W_i`$, el peso relativo de la $i$-ésima variable,
$`x_{jk}`$, la medida de tamaño del $j$-ésimo radio en el $k$-ésimo cluster,

```math
x_{\cdot k} = \sum_{j=1}^{N_k} x_{jk}
\hspace
\mbox{, y}
\qquad
x_{\cdot\cdot} = \sum_{k=1}^L \sum_{j=1}^{N_k} x_{jk}

```