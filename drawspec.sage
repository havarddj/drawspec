from tikz import *


class NumberFieldSpec():

    def __init__(self, F, nprimes=10):
        self._number_field = F
        self._fat_ramify = 1
        self._draw_random_line = False
        self._nprimes = nprimes
        self._color_classes = False
        self._quadratic_curve = False
        self._pic = self._draw_spec()

    def _draw_spec(self):
        return draw_spec(F=self._number_field,
                         npoints=self._nprimes,
                         fat_factor=self._fat_ramify,
                         draw_random_line=self._draw_random_line,
                         color_classes=self._color_classes,
                         quadratic_curve=self._quadratic_curve)

    def code(self):
        return self._pic.code()

    def pic(self):
        return self._pic

    def set_nprimes(self, nprimes):
        self._nprimes = nprimes
        self._pic = self._draw_spec()

    def fat_ramify(self, fat_factor):
        self._fat_ramify = fat_factor
        self._pic = self._draw_spec()

    def write_image(self, filename):
        return self._pic.write_image(filename)

    def color_classes(self, hlp):
        self._color_classes = hlp
        self._pic = self._draw_spec()

    def demo(self):
        return self.pic().demo()

    def quadratic_curve(self, flag):
        self._quadratic_curve = flag
        self._pic = self._draw_spec()


def draw_spec(F,
              npoints,
              fat_factor=1,
              draw_random_line=False,
              color_classes=False,
              quadratic_curve=False):

    prime_list = primes_first_n(npoints)
    # c = F.degree() / 2 + 1
    c = 2.5
    radius_factor = 1 / F.degree()

    d = F.degree()
    r = radius_factor * d

    pic = Picture()

    prime_id_list = [F.ideal(p).factor() for p in prime_list]
    coord_list = [
        fp_coords(fplist, n, c, r) for n, fplist in enumerate(prime_id_list)
    ]
    if color_classes:
        G = F.class_group()
        colors = []
        for i in range(G.order()):
            colors.append(generate_new_color(colors, pastel_factor=0.6))
        color_dict = dict(zip(list(G), colors))
        color_dict[G.identity()] = [.3, .3, .3]

    for n, fplist in enumerate(prime_id_list):
        pts = coord_list[n]
        for i, (fp, mult) in enumerate(fplist):
            if color_classes:
                rgb = color_dict[G(fp)]
                # print("rgb = ", rgb)
                color = f"rgb,1:red,{rgb[0]};green,{rgb[1]};blue,{rgb[2]}"
                color = "{" + color + "}"
            else:
                color = "black"
            pic.filldraw(pts[i],
                         circle(0.05 + fat_factor * (mult - 1) / 100),
                         fill=color)

    if draw_random_line:
        rand_current = randrange(len(coord_list[0]))
        rand_pt = coord_list[0][rand_current]
        for n in range(1, len(coord_list)):
            rand_next = randrange(len(coord_list[n]))
            if prime_id_list[n - 1][rand_current][1] > 1:
                outangle = -90 * sign(len(coord_list[n]) - 2.1 * rand_next)
            else:
                outangle = 0
            if prime_id_list[n][rand_next][1] > 1:
                inangle = 90 * sign(len(coord_list[n]) - 2.1 * rand_next)
            else:
                inangle = 180
            pic.draw(
                line([
                    coord_list[n - 1][rand_current], coord_list[n][rand_next]
                ],
                     op=f'to[out={outangle},in={inangle}]'))

            rand_current = rand_next

    if quadratic_curve:
        pic.draw()

    # draw generic points:
    pic.draw((npoints + 2, c), node("$(0)$"))
    if quadratic_curve:
        pic.draw(line([(npoints, c), (npoints + 1, c)]), dashed=True)

    # draw spec Z
    pic.filldraw(line([(0, 0), (npoints, 0)]))
    pic.draw(line([(npoints, 0), (npoints + 1, 0)]), dashed=True)

    pic.draw((npoints + 2, 0), node("$(0)$"))

    for n, p in enumerate(prime_list):
        pt = (n, 0)
        pic.filldraw(pt, circle(0.05))
        pic.draw(pt, node(f"$({p})$"), below=True)

    # for n in range(npoints):
    #     if len(points[n]) ==
    #     pic.filldraw(line())
    return pic


def fp_coords(fplist, x_coord, c, r):
    N = len(fplist)
    if N == 1:
        return [(x_coord, c)]
    else:
        return [(x_coord, c - r + 2 * r * i / (N - 1)) for i in range(N)]


def test_draw():
    npoints = 20
    K = NumberField(x ^ 3 + 15, "a")
    print("class number:", K.class_number())
    # K = QuadraticField(2)
    draw_spec(K, npoints, color_classes=True).write_image("test.pdf")
    return 0


# from https://gist.github.com/adewes/5884820:

import random


def get_random_color(pastel_factor=0.5):
    return [(x + pastel_factor) / (1.0 + pastel_factor)
            for x in [random.uniform(0, 1.0) for i in [1, 2, 3]]]


def color_distance(c1, c2):
    return sum([abs(x[0] - x[1]) for x in zip(c1, c2)])


def generate_new_color(existing_colors, pastel_factor=0.5):
    max_distance = None
    best_color = None
    for i in range(0, 100):
        color = get_random_color(pastel_factor=pastel_factor)
        if not existing_colors:
            return color
        best_distance = min(
            [color_distance(color, c) for c in existing_colors])
        if not max_distance or best_distance > max_distance:
            max_distance = best_distance
            best_color = color
    return best_color
