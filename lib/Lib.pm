#!/usr/bin/perl -w
# 
# Funciones para ser utilizadas desde listarC.pl
#
# Autor: Carlos Pantelides 74901
#
#



use strict;
use warnings;

package Lib;

our @EXPORT = qw(
	cargar_encuestadores
	cargar_preguntas
	cargar_encuestas
	evaluar_encuestador
	evaluar_numero
	evaluar_sitio
	evaluar_codigo
	procesar_argumentos
);

# codigo inimplementable pues perl es una mierda
# # lista o *
# sub evaluar_encuestador($\@\%) {
# 	my($id,@criterio,%encuestadores) = @_;
# # 	if($size == 0 ) {
# # 		return 1;
# # 	}
# 	print "Hash size: " . keys( %encuestadores ) . "\n";
# 	print "Array size: " . @criterio . "\n";
# #	Util::imprimir_criterios('Encuestadores', @criterio);
# 	return 1;
# }
# 
# # numero o rango
# sub evaluar_numero {
# 	my($numero,@criterio) = @_;
# 	return 1;
# }
# 
# # lista o *
# sub evaluar_sitio {
# 	my($sitio,@criterio) = @_;
# 	return 1;
# }
# 
# # lista o *
# sub evaluar_codigo {
# 	my($codigo,@criterio,%encuestas) = @_;
# 	return 1;
# }


# our %data = (
#	 a => {
#		 ab => 1,
#		 ac => 2
#	 },
#	 b => {
#		 ada => 3,
#		 adb => 4,
#		 adca => 5,
#		 adcb => 6,
#	 },
#	 c => {
#		 ca => 8,
#		 cba => 9,
#		 cbb => 10,
#	 },
# );

#
# Uso: cargar_encuestas(archivo) 
# 
# Devuelve un hash con la forma:
# codigo1=> { 
#   codigo => valor
#   nombre => valor
#   ...
# }
# codigo2=> { 
#   codigo => valor
#   nombre => valor
#   ...
# }
# El no poder cerrar el archivo no es un error fatal, asi que no se controla
#
sub cargar_encuestas($) {
	my ($archivo) = @_;
	my %lista;
	open(ARCHIVO,$archivo) || Util::dieWithCode ("No se pudo cargar $archivo: $!",5);
	while (<ARCHIVO>) {
		chomp;
		my %registro;
		( 
			$registro{"codigo"},
			$registro{"nombre"},
			$registro{"cantidad"},
			$registro{"rojo_inicio"},
			$registro{"rojo_fin"},
			$registro{"amarillo_inicio"},
			$registro{"amarillo_fin"},
			$registro{"verde_inicio"},
			$registro{"verde_fin"}
		) = split(/,/);

		$lista{$registro{"codigo"}}=\%registro;
	}
	close(ARCHIVO);
	return (%lista);
}

#
# Uso: cargar_encuestadores(archivo) 
# 
# Devuelve un hash con la forma:
# cuil1=> { 
#   cuil => valor
#   nombre => valor
#   ...
# }
# cuil2=> { 
#   cuil => valor
#   nombre => valor
#   ...
# }
# El no poder cerrar el archivo no es un error fatal, asi que no se controla
#
sub cargar_encuestadores($) {
	my ($archivo) = @_;
	my %lista;
	open(ARCHIVO,$archivo) || Util::dieWithCode ("No se pudo cargar $archivo: $!",5);
	while (<ARCHIVO>) {
		chomp;
		my %registro;
		( 
			$registro{"cuil"},
			$registro{"nombre"},
			$registro{"id"},
			$registro{"desde"},
			$registro{"hasta"}
		) = split(/,/);

		$lista{$registro{"id"}}=\%registro;
	}
	close(ARCHIVO);
	return (%lista);
}

#
# Uso: cargar_preguntas(archivo) 
# 
# Devuelve un hash con la forma:
# id1=> { 
#   id => valor
#   pregunta => valor
#   ...
# }
# id2=> { 
#   id => valor
#   pregunta => valor
#   ...
# }
# El no poder cerrar el archivo no es un error fatal, asi que no se controla
#
sub cargar_preguntas($){
	my ($archivo) = @_;
	my %lista;
	open(ARCHIVO,$archivo) || Util::dieWithCode ("No se pudo cargar $archivo: $!",5);
	while (<ARCHIVO>) {
		chomp;
		my %registro;
		( 
			$registro{"id"},
			$registro{"pregunta"},
			$registro{"tipo"},
			$registro{"ponderacion"}
		) = split(/,/);

		$lista{$registro{"id"}}=\%registro;
	}
	close(ARCHIVO);
	return (%lista);
}

# sub cargar_suma {
#	 my ($archivo) = @_;
#	 my %lista;
#	 open(ARCHIVO,$archivo) || die ("No se pudo cargar $archivo: $!");
#	 while (<ARCHIVO>) {
#		 chomp;
#		 my %registro;
#		 ( 
#			 $registro{"encuestador"},
#			 $registro{"fecha"},
#			 $registro{"numero"},
#			 $registro{"codigo"},
#			 $registro{"puntaje"},
#			 $registro{"cliente"},
#			 $registro{"sitio"},
#			 $registro{"modalidad"},
#			 $registro{"persona"}
#		 ) = split(/,/);
# 
#		 $lista{$registro{"encuestador"}}=\%registro;
#	 }
#	 close(ARCHIVO);
#	 return (%lista);
# }


1;