INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_pharmacie', 'Pharmacie', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_pharmacie', 'Pharmacie', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_pharmacie', 'Pharmacie', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('pharma','Pharmacien')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('pharma',0,'recruit','Stagiaire',20,'{}','{}'),
	('pharma',1,'boss','Patron',100,'{}','{}')
;