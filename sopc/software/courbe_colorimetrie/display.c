#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <io.h>

#include "system.h"
#include "display.h"

void display_pixel(int pos_x, int pos_y, short color)
{
	if (pos_x < H_RES && pos_y < V_RES)
	{
		IOWR(COLORIMETRIE_0_BASE, WRITE_RAM_WE, 0x0);
		IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_VALUE, color);
		IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_ADDR, PIXEL(pos_x, pos_y));
		IOWR(COLORIMETRIE_0_BASE, WRITE_RAM_WE, 0x1);
	}
}

void display_clean()
{
	int i;
	IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_VALUE, WHITE);
	IOWR(COLORIMETRIE_0_BASE, WRITE_RAM_WE, 0x1);
	for (i = 0; i < PIXEL_ADDR_MAX; i++)
		IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_ADDR, i);
	IOWR(COLORIMETRIE_0_BASE, WRITE_RAM_WE, 0x0);
}


void display_repere()
{
	int i;
	IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_VALUE, BLACK);
	IOWR(COLORIMETRIE_0_BASE, WRITE_RAM_WE, 0x1);
	for (i = 50; i < 430; i++)
	{
		IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_ADDR, PIXEL(DEBUT_AXE_X-1, i));
		IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_ADDR, PIXEL(DEBUT_AXE_X-2, i));
		IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_ADDR, PIXEL(DEBUT_AXE_X-3, i));
	}
	for (i = 50; i < 600; i++)
	{
		IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_ADDR, PIXEL(i, ORIGIN_AXE_Y+1));
		IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_ADDR, PIXEL(i, ORIGIN_AXE_Y+2));
		IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_ADDR, PIXEL(i, ORIGIN_AXE_Y+3));
	}
	IOWR(COLORIMETRIE_0_BASE, WRITE_RAM_WE, 0x0);

	for (i = 50; i < 430; i+=10)
	{
		display_pixel(DEBUT_AXE_X-4, i, BLACK);
		display_pixel(DEBUT_AXE_X-5, i, BLACK);
		display_pixel(DEBUT_AXE_X-6, i, BLACK);
	}

}
