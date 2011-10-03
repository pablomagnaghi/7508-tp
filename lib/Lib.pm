#!/usr/bin/perl -w

use strict;
use warnings;

package Lib;

our @EXPORT = qw(
    cargar_encuestadores
    cargar_preguntas
    cargar_suma
    cargar_encuestas
);

our %data = (
    a => {
        ab => 1,
        ac => 2
    },
    b => {
        ada => 3,
        adb => 4,
        adca => 5,
        adcb => 6,
    },
    c => {
        ca => 8,
        cba => 9,
        cbb => 10,
    },
);


sub cargar_encuestas {
    my ($archivo) = @_;
    my %lista;
    open(ARCHIVO,$archivo) || die ("No se pudo cargar $archivo: $!");
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

sub cargar_encuestadores {
    my ($archivo) = @_;
    my %lista;
    open(ARCHIVO,$archivo) || die ("No se pudo cargar $archivo: $!");
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

        $lista{$registro{"cuil"}}=\%registro;
    }
    close(ARCHIVO);
    return (%lista);
}

sub cargar_preguntas {
    my ($archivo) = @_;
    my %lista;
    open(ARCHIVO,$archivo) || die ("No se pudo cargar $archivo: $!");
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

sub cargar_suma {
    my ($archivo) = @_;
    my %lista;
    open(ARCHIVO,$archivo) || die ("No se pudo cargar $archivo: $!");
    while (<ARCHIVO>) {
        chomp;
        my %registro;
        ( 
            $registro{"encuestador"},
            $registro{"fecha"},
            $registro{"numero"},
            $registro{"codigo"},
            $registro{"puntaje"},
            $registro{"cliente"},
            $registro{"sitio"},
            $registro{"modalidad"},
            $registro{"persona"}
        ) = split(/,/);

        $lista{$registro{"encuestador"}}=\%registro;
    }
    close(ARCHIVO);
    return (%lista);
}

1;