#!/usr/bin/perl -w
# 
# 
#
# Autor: Carlos Pantelides 74901
#
# valores de exit:
# 0: ejecucion exitosa
# 1: ayuda
# 2: argumento desconocido
# 3: salida no especificada
# 4: criterio vacio
# 5: falla lectura archivo

# Suposiciones:
# encuestas.sum esta bien formado y es válido
# 
 

use strict;
use warnings;

# adaptado de http://www.perlmonks.org/index.pl?node_id=162876
my $libpath; 
BEGIN {
  $libpath = $ENV{GRUPO} . "/lib";
}

use lib $libpath || die("no libpath");;
use Util;
use Lib;

my $grupo=$ENV{GRUPO};
my $suma_encuestas=$ENV{ARCHIVO_ENCUESTAS};
my $directorio_reportes=$ENV{DIRECTORIO_YA};

# @todo: controlar variables de entorno

my $maestro_encuestadores="$grupo/mae/encuestadores.mae";
my $maestro_encuestas="$grupo/mae/encuestas.mae";
my $maestro_preguntas="$grupo/mae/preguntas.mae";

my $salida_pantalla = 0;
my $salida_archivo  = 0;
my $salida_ficha    = 0;

my @criterio_encuestadores;
my @criterio_codigos;
my @criterio_numeros;
my @criterio_sitios;
my @criterio_agrupacion;


# @todo: Refactorizacion 1
# Llevar este codigo a Lib.pm
# Debe devolver los arrays, salida, estado error/ayuda

# @todo Refactorizacion 2
# Mover a una funcion el codigo duplicado de -E -S -M -C -A

my $indice  = 0;

my $ayuda   = 0;
my $error   = "";
my $exit    = 0;

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
		# Criterio encuestadores
		 my $fin_items= 0;
		 while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				 push(@criterio_encuestadores, ($ARGV[$indice])); 
			}
		}
		if ( $#criterio_encuestadores == -1) {
			$error .= "Debe proveer algun elemento para -E\n";
			$exit = 4;
		}
	} elsif ($elem eq '-C' ) {
		# Criterio codigos encuesta
		my $fin_items= 0;
		while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				push(@criterio_codigos, ($ARGV[$indice])); 
			}
		}
		if ( $#criterio_codigos == -1 ) {
			$error .= "Debe proveer algun elemento para -C\n";
			$exit = 4;
		}
	} elsif ($elem eq '-N') {
		# Criterio numero de encuesta
		# @TODO: uno o dos numeros
		my $fin_items= 0;
		while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				push(@criterio_numeros, ($ARGV[$indice])); 
			}
		}
		if ( $#criterio_numeros == -1 ) {
			$error .= "Debe proveer algun elemento para -N\n";
			$exit = 4;
		}
	} elsif ($elem eq '-S') {
		# Criterio sitio de encuesta
		my $fin_items= 0;
		while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				push(@criterio_sitios, ($ARGV[$indice])); 
			}
		}
		if ( $#criterio_sitios == -1 ) {
			$error .= "Debe proveer algun elemento para -S\n";
			$exit = 4;
		}

	} elsif ($elem eq '-A') {
		# Criterio de agrupacion
		my $fin_items= 0;
		while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				push(@criterio_agrupacion, ($ARGV[$indice])); 
			}
		}
		if ( $#criterio_agrupacion == -1 ) {
			$error .= "Debe proveer algun elemento para -A\n";
			$exit = 4;
		}
	} elsif ($elem eq '-F') {
		$salida_ficha = 1;
	} else {
		$error .= "Argumento desconocido $elem\n";
		$exit = 2;
	}
	$indice++;
}

if ( ! $exit && ! $ayuda && ( $salida_pantalla == 0 && $salida_archivo == 0) ) {
	$error .= "Debe proveer un destino -c o -e\n";
	$exit = 3;
}

if ($error) {
	print STDERR "Error: $error\n";
}

if ($error || $ayuda) {
	Lib::mostrar_ayuda;
}

if ($error) {
	exit $exit;
}

if ($ayuda) {
	exit 1;
}

if ($salida_pantalla) {
	print STDERR "Salida a pantalla seleccionada\n";
} 
if ($salida_archivo) {
	print STDERR "Salida a archivo seleccionada\n";
}
if (1) {

Util::imprimir_criterios('Encuestadores', @criterio_encuestadores);
Util::imprimir_criterios('Códigos', @criterio_codigos);
Util::imprimir_criterios('Números', @criterio_numeros);
Util::imprimir_criterios('Sitios', @criterio_sitios);
Util::imprimir_criterios('Agrupacion', @criterio_agrupacion);

}


# fin Refactorizacion 2


# fin Refactorizacion 1

my %encuestas     = Lib::cargar_encuestas($maestro_encuestas);
my %encuestadores = Lib::cargar_encuestadores($maestro_encuestadores);
my %preguntas     = Lib::cargar_preguntas($maestro_preguntas);

if (0) {
Util::imprimir_maestro(\%encuestas);
Util::imprimir_maestro(\%encuestadores);
Util::imprimir_maestro(\%preguntas);
}


my $rojo = 0;
my $amarillo = 0;
my $verde = 0;

my %lista;
open(ARCHIVO,$suma_encuestas) || Util::dieWithCode("No se pudo cargar $suma_encuestas: $!", 5);
while (<ARCHIVO>) {
chomp;
	my %registro;
	my $fecha;
	my $cliente;
	my $modalidad;
	my $persona;
	( 
		$registro{'encuestador'},
		$registro{'fecha'},
		$registro{'numero'},
		$registro{'codigo'},
		$registro{'puntaje'},
		$registro{'cliente'},
		$registro{'sitio'},
		$registro{'modalidad'},
		$registro{'persona'}
	) = split(/,/);

# +Encuestador: key de %encuestadores
# |        +Fecha:NO INTERESA
# |        |        +Numero: unico local
# |        |        |    +Codigo encuesta: key de %encuestas
# |        |        |    |   + Puntaje
# |        |        |    |   |  +codigo cliente: NO INTERESA
# |        |        |    |   |  |          +sitio
# |        |        |    |   |  |          | +modalidad: NO INTERESA
# |        |        |    |   |  |          | | +persona: NO INTERESA
# |        |        |    |   |  |          | | |
#ESTEPANO,20110909,1022,E03,12,30354444882,E,P,II

	# Refactorizacion: utilizar $cumple_criterios en lugar de las siguientes y 
	#                  aplicar optimización al flujo de evaluación.
	my $cumple_encuestadores = 0;
	my $cumple_numeros = 0;
	my $cumple_sitios = 0;
	my $cumple_codigos = 0;


	if( @criterio_encuestadores == 0 ) {
		$cumple_encuestadores = 1;
	} else {
		foreach (@criterio_encuestadores) {
			if ($registro{'encuestador'} =~ $_ ) {  # @TODO: USAR ANCHORS
				$cumple_encuestadores = 1;
				last;
			}
		}
	}

	if( @criterio_sitios == 0 ) {
		$cumple_sitios = 1;
	} else {
		foreach (@criterio_sitios) {
			if ($registro{'sitio'} =~ $_ ) { # @TODO: USAR ANCHORS
				$cumple_sitios = 1;
				last;
			}
		}
	}

	if( @criterio_codigos == 0 ) {
		$cumple_codigos = 1;
	} else {
		foreach (@criterio_codigos) {
			if ($registro{'codigo'} =~ $_ ) { # @TODO: USAR ANCHORS
				$cumple_sitios = 1;
				last;
			}
		}
	}

	if( @criterio_numeros == 0 ) {
		$cumple_numeros = 1;
	} elsif ( @criterio_numeros == 0 ) {
		if ($registro{'numero'} =~ $criterio_numeros[0] ) { # @TODO: USAR ANCHORS
			$cumple_numeros = 1;
		}
	} else {
		if ( $registro{'numero'} >= $criterio_numeros[0] && $registro{'numero'} <= $criterio_numeros[1]) {
			$cumple_numeros = 1;
		}
	}



	#controlar que $registro cumpla el criterio
	if ( $cumple_encuestadores
		&& $cumple_numeros
		&& $cumple_sitios
		&& $cumple_codigos
	) {
		my $color;
		if ( $registro{'puntaje'} <= $encuestas{$registro{'codigo'}}{'rojo_fin'} ) {
			$rojo++;
			$color = 'rojo';
		} elsif ( $registro{'puntaje'} >= $encuestas{$registro{'codigo'}}{'verde_inicio'} ) {
			$verde++;
			$color = 'verde';
		} else {
			$amarillo++;
			$color = 'amarillo';
		}

		if ($salida_ficha) {
			Lib::mostrar_ficha(
				*STDERR,
				$registro{'numero'},
				$registro{'encuestador'} . ' ' .$encuestadores{$registro{'encuestador'}}{'nombre'},
				$registro{'fecha'},
				$registro{'cliente'},
				$registro{'modalidad'},
				$registro{'sitio'},
				$registro{'persona'},
				$registro{'codigo'} . ' ' . $encuestas{$registro{'codigo'}}{'nombre'},
				$encuestas{$registro{'codigo'}}{'cantidad'},
				$registro{'puntaje'},
				$color
			);
		}
		print STDERR $registro{'puntaje'} . " corresponde a $color\n";
	}
	
}
close(ARCHIVO);


# mostrar resultados


