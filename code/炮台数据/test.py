from multiprocessing import Pool, cpu_count

def test(point,test_arg):
    import numpy as np

    def get_four_points(longitude, latitude):
        lon1 = round(longitude * 2) / 2
        lat1 = round(latitude * 2) / 2
        if lon1.is_integer(): lon1 += 0.5
        if lat1.is_integer(): lat1 += 0.5

        lon2 = lon1 - 1 if lon1 > longitude else lon1 + 1
        lat2 = lat1 - 1 if lat1 > latitude else lat1 + 1
        return [(lon1, lat1), (lon1, lat2), (lon2, lat1), (lon2, lat2)] 

    print(get_four_points(point[0],point[1]))
    print(np.array(test_arg))


if __name__ == "__main__":
    rows = [(0.1,0.2),(4.1,6.4),(2.4,3.6),(8.7,9.366),(5.44,44.56)]
    argument = [1,2,3,4,5]
    with Pool(5) as pool:
        # Map rows to worker processes
        pool.starmap(
            test,
            [(row, argument) for row in rows]
        )