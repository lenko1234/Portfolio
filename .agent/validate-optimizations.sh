#!/bin/bash

# Script de Validación de Optimizaciones PageSpeed
# Verifica que todas las optimizaciones estén implementadas correctamente

echo "🔍 Validando Optimizaciones PageSpeed Insights..."
echo ""

ERRORS=0
WARNINGS=0

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar
check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        ((ERRORS++))
    fi
}

check_warning() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${YELLOW}⚠${NC} $2"
        ((WARNINGS++))
    fi
}

cd /home/robert/apps/Portfolio

echo "📦 1. Verificando Recursos Externos..."
grep -q 'async defer' es/index.html && grep -q 'three.min.js' es/index.html
check $? "Three.js cargado con async defer"

grep -q 'async defer' es/index.html && grep -q 'tailwindcss' es/index.html
check $? "Tailwind CSS cargado con async defer"

grep -q 'preload' es/index.html && grep -q 'font' es/index.html
check $? "Google Fonts con preload"

grep -q 'display=swap' es/index.html
check $? "Google Fonts con font-display: swap"

echo ""
echo "🌐 2. Verificando Preconnect y DNS Prefetch..."
grep -q 'dns-prefetch.*cloudflare' es/index.html
check $? "DNS Prefetch para Cloudflare CDN"

grep -q 'dns-prefetch.*googleapis' es/index.html
check $? "DNS Prefetch para Google Fonts"

grep -q 'preconnect.*cloudflare' es/index.html
check $? "Preconnect para Cloudflare CDN"

grep -q 'preconnect.*googleapis' es/index.html
check $? "Preconnect para Google Fonts"

echo ""
echo "🖼️  3. Verificando Imágenes WebP..."
WEBP_COUNT=$(ls assets/*.webp 2>/dev/null | wc -l)
if [ $WEBP_COUNT -ge 12 ]; then
    echo -e "${GREEN}✓${NC} $WEBP_COUNT imágenes WebP creadas (esperado: 16)"
else
    echo -e "${RED}✗${NC} Solo $WEBP_COUNT imágenes WebP encontradas (esperado: 16)"
    ((ERRORS++))
fi

grep -q '<picture>' es/index.html
check $? "Elemento <picture> implementado"

grep -q 'srcset.*webp' es/index.html
check $? "srcset con imágenes WebP"

grep -q 'loading="lazy"' es/index.html
check $? "Lazy loading implementado"

grep -q 'decoding="async"' es/index.html
check $? "Decodificación asíncrona implementada"

echo ""
echo "⚡ 4. Verificando Optimizaciones de JavaScript..."
grep -q 'cachedWidth' es/index.html
check $? "Cache de dimensiones de ventana"

grep -q 'initHeroWhenReady' es/index.html
check $? "Inicialización inteligente de Three.js"

echo ""
echo "🎨 5. Verificando Critical CSS..."
grep -q 'Critical CSS for above-the-fold' es/index.html
check $? "Critical CSS inline"

echo ""
echo "📱 6. Verificando Meta Tags..."
grep -q 'theme-color' es/index.html
check $? "Meta tag theme-color"

grep -q 'color-scheme' es/index.html
check $? "Meta tag color-scheme"

echo ""
echo "📊 7. Comparando Tamaños de Imágenes..."
echo ""
echo "Imagen Original vs WebP (small):"
for img in assets/*.png; do
    base=$(basename "$img" .png)
    if [ -f "assets/${base}-small.webp" ]; then
        original_size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null)
        webp_size=$(stat -f%z "assets/${base}-small.webp" 2>/dev/null || stat -c%s "assets/${base}-small.webp" 2>/dev/null)
        reduction=$(echo "scale=1; (1 - $webp_size / $original_size) * 100" | bc)
        echo "  $base: $(numfmt --to=iec $original_size) → $(numfmt --to=iec $webp_size) (${reduction}% reducción)"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Todas las optimizaciones están implementadas correctamente!${NC}"
    echo ""
    echo "🚀 Próximos pasos:"
    echo "   1. Probar en PageSpeed Insights: https://pagespeed.web.dev/"
    echo "   2. Verificar en dispositivos móviles"
    echo "   3. Monitorear Core Web Vitals en producción"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Optimizaciones implementadas con $WARNINGS advertencias${NC}"
    exit 0
else
    echo -e "${RED}❌ Se encontraron $ERRORS errores y $WARNINGS advertencias${NC}"
    echo ""
    echo "Por favor, revisa los errores arriba y corrige los problemas."
    exit 1
fi
