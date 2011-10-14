#!/usr/bin/perl -w
# 
# Funciones para ser utilizadas desde listarC.pl
#
# Autor: Carlos Pantelides 74901
#
#



#use strict;
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


sub wildcard($) {
	my ($r) = @_;
	$r =~ s/\*/.*/g;
	$r =~ s/\?/./g;
	return '^' . $r . '$';
}

sub es_numero($) {
	return $_[0] =~ /^-?\d+$/;
}

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


sub mostrar_ficha {
	my ($numero,$usuario,$fecha,$cliente,$modalidad,$sitio,$persona,$encuesta,$preguntas,$puntaje,$color,@salidas) = @_;
	foreach my $OUT (@salidas) {
		print $OUT "Encuesta Nro: $numero realizada por $usuario el dia $fecha\n";
		print $OUT "\n";
		print $OUT "Cliente $cliente, Modalidad $modalidad, Sitio $sitio y Persona $persona\n";
		print $OUT "\n";
		print $OUT "Encuesta aplicada $encuesta compuesta por $preguntas preguntas\n";
		print $OUT "\n";
		print $OUT "Puntaje obtenido: $puntaje calificación: $color\n";
		print $OUT "--------------------------------------------------------------------------------\n";
	}
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

sub mostrar_ayuda {
	print STDERR "Modo de uso:\n";
	print STDERR "  listarC.pl salida [filtrado] [agrupacion] \n";
	print STDERR "  Selección de salida\n";
	print STDERR "    Pantalla: -c\n";
	print STDERR "    Archivo:  -e\n";
	print STDERR "  Criterios de filtrado\n";
	print STDERR "    Identificador encuestador: -E encuesta+\n";
	print STDERR "    Número de encuesta:        -N numero [numero]\n";
	print STDERR "    Código de encuesta:        -C codigo+\n";
	print STDERR "    Sitio de encuesta:         -S sitio+\n";
	print STDERR "  Criterios de agrupación\n";
	print STDERR "    -A [e n c s]+\n";
	print STDERR "\n";



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