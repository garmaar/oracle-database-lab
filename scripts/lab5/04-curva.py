import csv
import html
import math
import re
import sys
from pathlib import Path

source=Path(sys.argv[1])
destination=Path(sys.argv[2])
rows=[]
for line in source.read_text().splitlines():
    match=re.match(r'^([.\d]+) %\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(índice|recorrido completo)',line)
    if match:
        rows.append([float(match[1]),*[int(match[index]) for index in range(2,6)],match[6]])
assert len(rows)==12,'Se esperaban doce muestras de la ejecución'
with destination.with_suffix('.csv').open('w',newline='') as output:
    writer=csv.writer(output)
    writer.writerow(['k_pct','filas_estimadas','cf_bueno','cf_malo','full_scan','plan_cf_malo'])
    writer.writerows(rows)

def xpos(value):
    return 90+(math.log10(value)+2)*220

def ypos(value):
    return 490-math.log10(value)*63

svg=['<svg xmlns="http://www.w3.org/2000/svg" width="1050" height="620" viewBox="0 0 1050 620">',
     '<rect width="1050" height="620" fill="white"/>',
     '<g font-family="sans-serif" font-size="13" fill="#172033">',
     '<text x="90" y="32" font-size="21">TiendaSur: punto de equilibrio medido</text>',
     '<text x="90" y="57">Ejes logarítmicos; muestras reales, no predicciones de coste</text>']
for lower,upper,color in [(0.1,0.2,'#fef3c7'),(0.5,1,'#fee2e2'),(50,100,'#dbeafe')]:
    svg.append(f'<rect x="{xpos(lower):.2f}" y="85" width="{xpos(upper)-xpos(lower):.2f}" height="405" fill="{color}"/>')
for value in [10,100,1000,10000,100000,1000000]:
    position=ypos(value)
    svg.append(f'<path d="M90 {position:.2f} H970" stroke="#e2e8f0"/><text x="80" y="{position+4:.2f}" text-anchor="end">{value:,}</text>')
for value in [0.01,0.1,1,10,100]:
    position=xpos(value)
    svg.append(f'<path d="M{position:.2f} 85 V490" stroke="#e2e8f0"/><text x="{position:.2f}" y="514" text-anchor="middle">{value:g}%</text>')
for column,color,title in [(2,'#2563eb','Índice CF bueno'),(3,'#dc2626','Índice CF malo'),(4,'#475569','Recorrido completo')]:
    points=' '.join(f'{xpos(row[0]):.2f},{ypos(row[column]):.2f}' for row in rows)
    svg.append(f'<polyline fill="none" stroke="{color}" stroke-width="3" points="{points}"/>')
    for row in rows:
        svg.append(f'<circle cx="{xpos(row[0]):.2f}" cy="{ypos(row[column]):.2f}" r="3" fill="{color}"/>')
    legend_x=90+(column-2)*280
    svg.append(f'<text x="{legend_x}" y="552" fill="{color}">{html.escape(title)}</text>')
svg.extend(['<text x="90" y="578">Amarillo: cambio del optimizador (0,1–0,2%); rojo: cruce CF malo (0,5–1%).</text>',
            '<text x="90" y="601">Azul: cruce CF bueno (50–100%). El eje vertical representa lecturas lógicas.</text>',
            '</g></svg>'])
destination.with_suffix('.svg').write_text('\n'.join(svg)+'\n')
print('CSV y gráfico SVG generados a partir de',source.name)
