#!/usr/bin/perl -w

use strict;
use warnings;

use Util;
use Lib;
use Switch;


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



my $salida_pantalla = 0;
my $salida_archivo  = 0;

my @encuestadores;
my @codigos;
my @numeros;
my @sitios;
my @agrupacion;


# Refactorizacion 1
# Llevar este codigo a Util.pm
# Debe devolver los arrays, salida, estado error/ayuda

# Refactorizacion 2
# Mover a una funcion el codigo duplicado de -E -S -M -C -A

my $indice          = 0;

my $ayuda           = 0;
my $error           = "";


# if ($#ARGV == -1 ) {
#     $error .= "Debe proveer algún argumento\n";
# }

while ($indice < $#ARGV + 1  && ! $ayuda && ! $error) {
    my $elem = $ARGV[$indice];
    if ($elem =~ /-h/) {
        # Menu de ayuda
        $ayuda = 1;
    } elsif ($elem eq '-c' ) {
        # Consulta a pantalla

        $salida_pantalla = 1;
    } elsif ($elem eq '-e' ) {
        # Consulta a archivo
        $salida_archivo = 1;
    } elsif ($elem eq '-E' ) {
        # Encuestador
        my $fin_items= 0;
        while ($indice < $#ARGV && ! $fin_items) {
            $indice++;
            if ( $ARGV[$indice] =~ /^-.*/ ) {
                $indice--;
                $fin_items = 1;
            } else {
                push(@encuestadores, ($ARGV[$indice])); 
            }
        }
        if ( $#encuestadores == -1) {
           $error .= "Debe proveer algun elemento para -E\n";
        }
    } elsif ($elem eq '-C' ) {
        # Codigo encuesta
        my $fin_items= 0;
        while ($indice < $#ARGV && ! $fin_items) {
            $indice++;
            if ( $ARGV[$indice] =~ /^-.*/ ) {
                $indice--;
                $fin_items = 1;
            } else {
                push(@codigos, ($ARGV[$indice])); 
            }
        }
        if ( $#codigos == -1 ) {
           $error .= "Debe proveer algun elemento para -C\n";
        }
    } elsif ($elem eq '-N') {
        # Numero de encuesta
        my $fin_items= 0;
        while ($indice < $#ARGV && ! $fin_items) {
            $indice++;
            if ( $ARGV[$indice] =~ /^-.*/ ) {
                $indice--;
                $fin_items = 1;
            } else {
                push(@numeros, ($ARGV[$indice])); 
            }
        }
        if ( $#numeros == -1 ) {
           $error .= "Debe proveer algun elemento para -N\n";
        }
    } elsif ($elem eq '-S') {
        # Sitio de encuesta
        my $fin_items= 0;
        while ($indice < $#ARGV && ! $fin_items) {
            $indice++;
            if ( $ARGV[$indice] =~ /^-.*/ ) {
                $indice--;
                $fin_items = 1;
            } else {
                push(@sitios, ($ARGV[$indice])); 
            }
        }
        if ( $#sitios == -1 ) {
           $error .= "Debe proveer algun elemento para -S\n";
        }

    } elsif ($elem eq '-A') {
        # Agrupacion
        my $fin_items= 0;
        while ($indice < $#ARGV && ! $fin_items) {
            $indice++;
            if ( $ARGV[$indice] =~ /^-.*/ ) {
                $indice--;
                $fin_items = 1;
            } else {
                push(@agrupacion, ($ARGV[$indice])); 
            }
        }
        if ( $#agrupacion == -1 ) {
           $error .= "Debe proveer algun elemento para -A\n";
        }
    } else {
        $error .= "Argumento desconocido $elem\n";
    }
    $indice++;
}

if ( $#encuestadores == -1 && $#codigos == -1 && $#numeros == -1 && $#sitios == -1) {
   $error .= "Debe proveer algún criterio -A -C -N -S\n";
}

if ( $salida_pantalla == 0 && $salida_archivo == 0) {
    $error .= "Debe proveer un destino -c o -e\n";
}

if ($error) {
    print "Error: $error\n";
}

if ($error || $ayuda) {
    print "Mensaje de ayuda\n";
} else {
    if ($salida_pantalla) {
        print "Salida a pantalla seleccionada\n";
    } 
    if ($salida_archivo) {
       print "Salida a archivo seleccionada\n";
    }
    Util::imprimir_argumentos('Encuestadores', @encuestadores);
    Util::imprimir_argumentos('Códigos', @codigos);
    Util::imprimir_argumentos('Números', @numeros);
    Util::imprimir_argumentos('Sitios', @sitios);
    Util::imprimir_argumentos('Agrupacion', @agrupacion);
}

# fin Refactorizacion 2


# fin Refactorizacion 1


if (0) {
    my %encuestas = Lib::cargar_encuestas($maestro_encuestas);
    Util::imprimir_lista(\%encuestas);

    my %encuestadores = Lib::cargar_encuestadores($maestro_encuestadores);
    Util::imprimir_lista(\%encuestadores);

    my %preguntas = Lib::cargar_preguntas($maestro_preguntas);
    Util::imprimir_lista(\%preguntas);

    #my %suma = Lib::cargar_suma($suma_encuestas);
    #Util::imprimir_lista(\%suma);
}

# encuestador= *                 -E
# codigo_encuesta= *             -C 
# numero_encuesta=1, rango, *    -N
# sitio_encuensta= *             -S
# 
# -c 
# -e
# -h
# 
# outdir=ya
# reportname=fecha:hora.txt
