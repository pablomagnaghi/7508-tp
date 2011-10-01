#!/usr/bin/perl -w

# Los datos que hacen falta de la configuracion son:
#    ~/grupo2/mae
#    ~/grupo2/ya/encuestas.sum
#    ~/grupo2/ya/ 
# No hace falta parsear la configuracion, pues tanto "~" como "grupo2" deben ser
# conocidos programaticamente, ya que la configuracion se halla en ~/grupo2/conf

# $raiz="~/grupo2";
$raiz="/home/carlos/7508/svn/trunk";

$suma_encuestas="$raiz/ya/encuestas.sum";
$maestro_encuestadores="$raiz/mae/encuestadores.mae";
$maestro_encuestas="$raiz/mae/encuestas.mae";
$maestro_preguntas="$raiz/mae/preguntas.mae";

# tomado de 
# http://stackoverflow.com/questions/2363142/how-to-iterate-through-hash-of-hashes-in-perl
sub hash_walk {
    my ($hash, $key_list, $callback) = @_;
    while (my ($k, $v) = each %$hash) {
        # Keep track of the hierarchy of keys, in case
        # our callback needs it.
        push @$key_list, $k;

        if (ref($v) eq 'HASH') {
            # Recurse.
            hash_walk($v, $key_list, $callback);
        }
        else {
            # Otherwise, invoke our callback, passing it
            # the current key and value, along with the
            # full parentage of that key.
            $callback->($k, $v, $key_list);
        }

        pop @$key_list;
    }
}


sub print_hash {
    my ($hash) = @_;
    print "PRINT HASH\n";
    while (my ($key, $value) = each %$hash) {
        print ".\n";
        if ('HASH' eq ref $value) {
            print "HASH";
            print_hash $value;
        } else {
            print "VALUE";
            #$fn->($value);
            print $value;
        }
    }
}

#
#
#
sub cargar_encuestas {
    open(ARCHIVO,$maestro_encuestas) || die ("No se pudo cargar encuestas: $! $maestro_encuestas");
    while (<ARCHIVO>) {
        chomp;
        ( 
            $encuesta{"codigo"},
            $encuesta{"nombre"},
            $encuesta{"cantidad"},
            $encuesta{"rojo_inicio"},
            $encuesta{"rojo_fin"},
            $encuesta{"amarillo_inicio"},
            $encuesta{"amarillo_fin"},
            $encuesta{"verde_inicio"},
            $encuesta{"verde_fin"}
        ) = split(/,/);

        $lista_encuestas{$encuesta{"codigo"}}=$encuesta;
        print_hash $encuesta;
    }
    close(ARCHIVO);
    
    print_hash $lista_encuestas;

    return (%lista_encuestas);
}

%encuestas = cargar_encuestas();
# foreach $encuesta (cargar_encuestas()) {
#   print $encuesta{"codigo"};
#   foreach $campo (%encuesta) {
#     print "$campo, ";
#   }
#   print "\n";
# }

#%encuestas=;

#%encuestadores=;

#%preguntas=;
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




