# Huellas de la Entropía en el Fenómeno de Criticalidad Autoorganizada

Este repositorio contiene el código y materiales relacionados con mi Trabajo de Fin de Grado (TFG), titulado **"Huellas de la Entropía en el Fenómeno de Criticalidad Autoorganizada"**. El objetivo del proyecto es el estudio de sistemas complejos utilizando simulaciones computacionales, con un enfoque en la **criticalidad autoorganizada (SOC)** a través del modelo de Olami-Feder-Christensen (OFC).

## Descripción del Proyecto

- Implementación del modelo **OFC** en Python.
- Simulaciones computacionales de sistemas de criticalidad autoorganizada.
- Cálculo de la **entropía de Shannon** para caracterizar la dinámica del sistema.
- Análisis de distribuciones de avalanchas y validación de leyes de potencias.
- Aplicación de técnicas de **Machine Learning** para el análisis de patrones.

## Estructura del Repositorio

```
📂 TFG_SOC
├── 📜 README.md  # Descripción del proyecto
├── 📜 requirements.txt  # Dependencias necesarias
├── 📂 src  # Código fuente del modelo OFC
│   ├── ofc_model.py  # Implementación del modelo
│   ├── visualization.py  # Herramientas para visualización 2D y 3D
│   ├── entropy_analysis.py  # Cálculo de entropía
│   ├── avalanche_analysis.py  # Estudio de distribución de avalanchas
│   └── utils.py  # Funciones auxiliares
├── 📂 notebooks  # Análisis interactivos en Jupyter
│   ├── exploratory_analysis.ipynb
│   ├── entropy_study.ipynb
│   ├── avalanche_distributions.ipynb
│   └── neural_networks_patterns.ipynb  # Experimentos con ML
├── 📂 data  # Datos generados por las simulaciones
└── 📂 figures  # Visualizaciones y gráficos generados
```

## Requisitos

Para ejecutar el código, instala las dependencias con:
```bash
pip install -r requirements.txt
```

## Uso

Ejecuta una simulación básica del modelo OFC con:
```bash
python src/ofc_model.py --size 50 --steps 10000
```
Para visualizar las redes:
```bash
python src/visualization.py --mode 3D
```

## Contacto
Para dudas o sugerencias, puedes contactarme o abrir un *issue* en el repositorio.

---

Este README se va a ampliar con ejemplos de uso y explicaciones más detalladas a medida que el proyecto avance :)

