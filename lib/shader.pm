#!/opt/local/bin/perl

# #########################################################################
#
# die Shader
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package shader;

use strict;
use warnings;

use OpenGL qw(:all);
use OpenGL::Image;
use OpenGL::Shader;

use lib "lib";

# meine Konstanten fuer die Shader

my @shader = ( "metal",
             );

my %shader;
my $shaderInit = 0;

my ($VertexProgID, $FragProgID);

sub init {

    # Lade einen Shader
    ($VertexProgID,$FragProgID) = glGenProgramsARB_p(2);

    # NOP Vertex shader
    my $VertexProg = qq
    {!!ARBvp1.0
    TEMP vertexClip;
    DP4 vertexClip.x, state.matrix.mvp.row[0], vertex.position;
    DP4 vertexClip.y, state.matrix.mvp.row[1], vertex.position;
    DP4 vertexClip.z, state.matrix.mvp.row[2], vertex.position;
    DP4 vertexClip.w, state.matrix.mvp.row[3], vertex.position;
    MOV result.position, vertexClip;
    MOV result.color, vertex.color;
    MOV result.texcoord[0], vertex.texcoord;
    END
    };

    glBindProgramARB(GL_VERTEX_PROGRAM_ARB, $VertexProgID);
    glProgramStringARB_p(GL_VERTEX_PROGRAM_ARB, $VertexProg);
    #my $vprog = glGetProgramStringARB_p(GL_VERTEX_PROGRAM_ARB);
    #print "Vertex Prog: '$vprog'\n";

    # Lazy Metallic Fragment shader
    my $FragProg = qq
    {!!ARBfp1.0
    TEMP color;
    MUL color, fragment.texcoord[0].y, 2;
    ADD color, 1, -color;
    ABS color, color;
    ADD result.color, 1.01, -color;
    MOV result.color.a, 1;
    END
    };

    glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB, $FragProgID);
    glProgramStringARB_p(GL_FRAGMENT_PROGRAM_ARB, $FragProg);
    #my $fprog = glGetProgramStringARB_p(GL_FRAGMENT_PROGRAM_ARB);
    #print "Fragment Prog: '$fprog'\n";

    $shaderInit = 1;
}

#
# Lade einen Shader
#
sub ladeShader
{

}

#
# binde einen geladenen Shader
#
sub bind {

    my $shaderName = shift @_;

    if(! $shaderInit) {
        &init();
    };

}

#
# Loesche alle Shader
#
sub beende {

    if($shaderInit) {
        glBindProgramARB(GL_VERTEX_PROGRAM_ARB, 0);
        glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB, 0);
        glDeleteProgramsARB_p($VertexProgID,$FragProgID);
    }
}

1;
