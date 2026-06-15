CREATE TABLE lectores (
    id SERIAL PRIMARY KEY
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    fecha_nacimiento DATE
);

CREATE TABLE libros (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(100),
    editorial VARCHAR(100),
    autor VARCHAR(100),
    isbn VARCHAR(20) UNIQUE
	);


INSERT INTO lectores (nombre, apellido, email, fecha_nacimiento) VALUES
('Juan Alberto', 'Cortéz', 'juancortez@gmail.com', '1983-06-20'),
('Antonia', 'de los Ríos', 'antoniarios_23@yahoo.com', '1978-11-24'),
('Nicolás', 'Martin', 'nico_martin23@gmail.com', '1986-07-11'),
('Néstor', 'Casco', 'nestor_casco2331@hotmmail.com', '1981-02-11'),
('Lisa', 'Pérez', 'lisperez@hotmail.com', '1994-08-11'),
('Ana Rosa', 'Estagnolli', 'anros@abcdatos.com', '1974-10-15'),
('Milagros', 'Pastoruti', 'mili_2231@gmail.com', '2001-01-22'),
('Pedro', 'Alonso', 'alonso.pedro@impermebilizantesrosario.com', '1983-09-05'),
('Arturo Ezequiel', 'Ramírez', 'artu.rama@outlook.com', '1998-03-29'),
('Juan Ignacio', 'Altarez', 'juanaltarez.223@yahoo.com', '1975-08-24');

SELECT * FROM lectores;


INSERT INTO libros (titulo, editorial, autor, isbn) VALUES
('Cementerio de animales', 'Ediciones de Mente', 'Stephen King', '4568874'),
('En el nombre de la rosa', 'Editorial España', 'Umberto Eco', '44558877'),
('Cien años de soledad', 'Sudamericana', 'Gabriel García Márquez', '7788845'),
('El diario de Ellen Rimbauer', 'Editorial Maine', 'Stephen King', '45699874'),
('La hojarasca', 'Sudamericana', 'Gabriel García Márquez', '7787898'),
('El amor en los tiempos del cólera', 'Sudamericana', 'Gabriel García Márquez', '2564111'),
('La casa de los espíritus', 'Ediciones Chile', 'Isabel Allende', '5544781'),
('Paula', 'Ediciones Chile', 'Isabel Allende', '22545447'),
('La tregua', 'Alfa', 'Mario Benedetti', '2225412'),
('Gracias por el fuego', 'Alfa', 'Mario Benedetti', '88541254');

SELECT * FROM libros;

CREATE TABLE prestamos (
    id SERIAL PRIMARY KEY,
    lector_id INTEGER REFERENCES lectores (id),
    libro_id INTEGER REFERENCES libros (id),
    fecha_prestamo DATE DEFAULT CURRENT_DATE   
);
-- Lectores con 5 libros cada uno
INSERT INTO prestamos (lector_id, libro_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(2, 1), (2, 6), (2, 7), (2, 8), (2, 2),
(3, 3), (3, 5), (3, 6), (3, 7), (3, 9),
(4, 1), (4, 4), (4, 6), (4, 8), (4, 9);

-- Lectores con 3 libros cada uno
INSERT INTO prestamos (lector_id, libro_id) VALUES
(5, 1), (5, 2), (5, 3),
(6, 4), (6, 5), (6, 6),
(7, 7), (7, 8), (7, 9);

-- Lectores con 1 libro
INSERT INTO prestamos (lector_id, libro_id) VALUES
(8, 5),
(9, 6);

--Lector sin libros: ID 10

--Libro no prestado: ID 10 (libro con id = 10)
SELECT * FROM prestamos;


SELECT
    libros.titulo,
    COUNT(prestamos.id) AS veces_prestado
    FROM libros
    LEFT JOIN prestamos ON libros.id = prestamos.libro_id
    GROUP BY libros.titulo
    ORDER BY veces_prestado DESC;

SELECT
    lectores.nombre || ' ' || lectores.apellido AS lector,
    COUNT(prestamos.id) AS cantidad_libros
    FROM lectores
    LEFT JOIN prestamos ON lectores.id = prestamos.lector_id
    GROUP BY lectores.id, lectores.nombre, lectores.apellido
    ORDER BY cantidad_libros DESC;

DELETE FROM prestamos
WHERE lector_id = 1 AND libro_id = 1;

SELECT
    lectores.nombre || ' ' || lectores.apellido AS lector,
    COUNT(prestamos.id) AS cantidad_libros,
    STRING_AGG(libros.titulo, ', ') AS libros_prestados
    FROM lectores
    LEFT JOIN prestamos ON lectores.id = prestamos.lector_id
    LEFT JOIN libros ON prestamos.libro_id = libros.id
    GROUP BY lectores.id, lectores.nombre, lectores.apellido
    ORDER BY cantidad_libros DESC;


	

-- Edad promedio
SELECT ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_nacimiento)))) AS promedio_edad
FROM lectores;

SELECT 
    'Más joven' AS tipo,
    nombre || ' ' || apellido AS lector,
    fecha_nacimiento,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_nacimiento)) AS edad
    FROM lectores
    ORDER BY fecha_nacimiento DESC
    LIMIT 1


SELECT 
    'Más años' AS tipo,
    nombre || ' ' || apellido AS lector,
    fecha_nacimiento,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_nacimiento)) AS edad
    FROM lectores
    ORDER BY fecha_nacimiento ASC
    LIMIT 1;

CREATE VIEW libros_prestados AS
SELECT 
    l.nombre || ' ' || l.apellido AS lector,
    b.titulo,
    b.editorial,
    b.isbn
   FROM prestamos p
   JOIN lectores l ON p.lector_id = l.id
   JOIN libros b ON p.libro_id = b.id;


SELECT * FROM libros_prestados
WHERE lector = 'Pedro Alonso';



CREATE OR REPLACE PROCEDURE devolver_libro(p_lector_id INT, p_libro_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM prestamos
    WHERE lector_id = p_lector_id AND libro_id = p_libro_id;
END;
$$;


CALL devolver_libro(1, 3); 

SELECT * FROM prestamos
WHERE lector_id = 1 AND libro_id = 3;

CREATE TABLE log_devoluciones (
    id SERIAL PRIMARY KEY,
    lector_id INT,
    libro_id INT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION registrar_log_devolucion()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_devoluciones (lector_id, libro_id)
    VALUES (OLD.lector_id, OLD.libro_id);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_devolucion
AFTER DELETE ON prestamos
FOR EACH ROW
EXECUTE FUNCTION registrar_log_devolucion();



CALL devolver_libro(1, 2);
CALL devolver_libro(2, 6);
CALL devolver_libro(3, 9);

SELECT * FROM log_devoluciones;

SELECT * FROM prestamos;

CREATE OR REPLACE FUNCTION libros_prestados()
RETURNS INT AS $$
DECLARE
    total INT;
BEGIN
    SELECT COUNT(*) INTO total FROM prestamos;
    RETURN total;
END;
$$ LANGUAGE plpgsql;


SELECT libros_prestados();


















    


































