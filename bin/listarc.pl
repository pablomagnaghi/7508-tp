#!/usr/bin/perl -w

use strict;
use warnings;

use Util;
use Lib;

# Los datos que hacen falta de la configuracion son:
#    ~/grupo2/mae
#    ~/grupo2/ya/encuestas.sum
#    ~/grupo2/ya/ 
# No hace falta parsear la configuracion, pues tanto "~" como "grupo2" deben ser
# conocidos programaticamente, ya que la configuracion se halla en ~/grupo2/conf

# $raiz="~/grupo2";
my $raiz="/home/carlos/7508/7508fiuba2011g2/trunk";

my $suma_encuestas="$raiz/ya/encuestas.sum";
my $maestro_encuestadores="$raiz/mae/encuestadores.mae";
my $maestro_encuestas="$raiz/mae/encuestas.mae";
my $maestro_preguntas="$raiz/mae/preguntas.mae";


my %encuestas = Lib::cargar_encuestas($maestro_encuestas);
Util::imprimir_lista(\%encuestas);

my %encuestadores = Lib::cargar_encuestadores($maestro_encuestadores);
Util::imprimir_lista(\%encuestadores);

my %preguntas = Lib::cargar_preguntas($maestro_preguntas);
Util::imprimir_lista(\%preguntas);

my %suma = Lib::cargar_suma($suma_encuestas);
Util::imprimir_lista(\%suma);


#
#
#
# encuestador= *
# codigo_encuesta= *
# numero_encuesta=1, rango, *
# sitio_encuensta= *
# 
# -c 
# -e
# -h
# 
# outdir=ya
# reportname=fecha:hora.txt




