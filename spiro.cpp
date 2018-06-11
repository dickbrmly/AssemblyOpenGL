#include <cstdlib>
#include <iostream>
#include <GL/gl.h>
#include <GL/glut.h>
#include <GL/freeglut.h>

using	namespace	std;

// ----------------------------------------------------------------------
//  CS 218 -> Assignment #10
//  Spirograph Program.
//  Provided main...

//  Uses openGL (which must be installed).
//  openGL installation:
//	sudo apt-get update
//	sudo apt-get upgrade
//	sudo apt-get install freeglut3-dev

//  Compilation:
//	g++ -g -c spiro.cpp -lglut -lGLU -lGL -lm


// ----------------------------------------------------------------------
//  External functions (in seperate file).

extern "C" void spirograph();
extern "C" int getRadii(int, char* [], int *, int *, int *, char *);

// ----------------------------------------------------------------------
//  Global variables
//	Must be accessible for openGL display routine, spirograph().

int	radius1 =0xaf;			// radius 1
int	radius2 =0x2a;			// radius 2
int	position =0x45;			// offset position
char	color='b';				// plot color letter code


// ----------------------------------------------------------------------
//  Key handler function.
//	Terminates for 'x', 'q', or ESC key.
//	Ignores all other characters.

void	keyHandler(unsigned char key, int x, int y)
{
	if (key == 'x' || key == 'q' || key == 27) {
		glutLeaveMainLoop();
		exit(0);
	}
}

// ----------------------------------------------------------------------
//  Main routine.

int main(int argc, char* argv[])
{
	int	height = 500;
	int	width = 500;

	double	left = -350.0;
	double	right = 350.0;
	double	bottom = -350.0;
	double	top = 350.0;

	bool	stat =true;

	//stat = getRadii(argc, argv, &radius1, &radius2, &position, &color);

	if (stat) {

		// Debug call for display function	
		//spirograph();

		glutInit(&argc, argv);
		glutInitDisplayMode(GLUT_RGB | GLUT_SINGLE);
		glutInitWindowSize(width, height);
		glutInitWindowPosition(35, 30);
		glutCreateWindow("CS 218 Assignment #10 - Spirograph Program");
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
 		glClear (GL_COLOR_BUFFER_BIT);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrtho(left, right, bottom, top, 0.0, 1.0);
	
		glutKeyboardFunc(keyHandler);
		glutDisplayFunc(spirograph);

		glutMainLoop();
	}

	return 0;
}

