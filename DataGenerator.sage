import os
import functools
import json
import pathlib
import logging as log

class DataGenerator:
    def __init__(self, groups, output="Data", mdh=False):
        self.output = output
        groups_left = len(groups)
        all_data = []
        for group in groups:
            try:
                log.info(f"{group}")
                log.info("Determing common properties")
                common = Common(group)
                log.info("Common properties determined")

                log.info("Determining EKR property")
                ekr = DeterminerEKR(common)
                log.info("EKR property determined")

                log.info("Determining EKR-module property")
                ekrm = DeterminerEKRM(common, ekr)
                log.info("EKR-module property determined")

                log.info("Determining strict EKR property")
                strict_ekr = DeterminerEKRStrict(common, ekr, ekrm)
                log.info("Strict EKR property determined")

                log.info("Saving data")
                data = {
                    "name": str(group),
                    "transitive number": group.transitive_number(),
                    "id": group.group_id(),
                    "degree": common.degree,
                    "number": self._get_number(common),
                    "order": common.order,
                    "transitivity": common.transitivity,
                    "eigenvalues": self._get_nice_eigenvalues(common),
                    "ekr": ekr.has_ekr,
                    "ekr reasons": ekr.reasons,
                    "ekrm": ekrm.has_ekrm,
                    "ekrm reasons": ekrm.reasons,
                    "sekr": strict_ekr.has_strict_ekr,
                    "sekr reasons": strict_ekr.reasons,
                    "abelian": group.is_abelian(),
                    "nilpotent": group.is_nilpotent(),
                    "primitive": group.is_primitive(),
                }

                if mdh:
                    all_data += [self._mdh_json(data)]
                else:
                    self._save(data)
                log.info("Data saved")

                groups_left -= 1
                print(f"\rGroups left: {groups_left}\r", end="")
        
            except Exception as e:
                log.error(f"While checking the EKR properties of {group} we encountered the error {e}\n\n\n")
                skipped_log = open("skipped.txt", "a")
                skipped_log.write(f"{group}\n\n\n")
                skipped_log.close()
                groups_left -= 1

        if mdh:
            self._save_mdh(all_data)

    def _get_number(self, common):
        name = str(common.group)

        number_start_index = 24
        number = ""
        for char in name[number_start_index:]:
            if char.isdigit():
                number += char
            else:
                break
        
        return number
    
    def _get_nice_eigenvalues(self, common):
        eigenvalues = common.eigenvalues
        eigenvalues_with_multiplicities = common.eigenvalues_with_multiplicities

        eigenvalues_nice = []
        for eigenvalue in eigenvalues:
            eigenvalues_nice.append((eigenvalue, eigenvalues_with_multiplicities.count(eigenvalue)))
        
        return eigenvalues_nice
    
    def _save(self, data):
        if os.path.exists(self.output):
            assert os.path.isdir(self.output), "{0} exists but is not a directory".format(self.output)
        else:
            print ("Creating directory: {0}".format(self.output))
            pathlib.Path(self.output).mkdir(parents=True, exist_ok=True)

        name = data["name"]
        degree = data["degree"]
        number = data["number"]
        order = data["order"]
        transitivity = data["transitivity"]
        eigenvalues = data["eigenvalues"]
        ekr = data["ekr"] 
        ekr_reasons = data["ekr reasons"]
        ekrm = data["ekrm"]
        ekrm_reasons = data["ekrm reasons"]
        sekr = data["sekr"] 
        sekr_reasons = data["sekr reasons"]
        abelian = data["abelian"]
        nilpotent = data["nilpotent"]
        primitive = data["primitive"]
        
        contents = f"{name}\n\n"
        contents += f"Order: {order}\n\n"
        contents += f"Transitivity: {transitivity}\n\n"
        contents += f"Eigenvalues: {eigenvalues}\n\n"
        contents += f"EKR Property: {ekr} as {ekr_reasons}\n\n"
        contents += f"EKRM Property: {ekrm} as {ekrm_reasons}\n\n"
        contents += f"Strict EKR Property: {sekr} as {sekr_reasons}\n\n"
        contents += f"Abelian: {abelian}\n\n"
        contents += f"Nilpotent: {nilpotent}\n\n"
        contents += f"Primitive: {primitive}\n\n"

        degree_path = f"{self.output}/{degree}"
        if os.path.exists(degree_path):
            assert os.path.isdir(degree_path), "{0} exists but is not a directory".format(degree_path)
        else:
            print ("Creating directory: {0}".format(degree_path))
            pathlib.Path(degree_path).mkdir(parents=True, exist_ok=True)
        data_file = open(f"{degree_path}/{number}", "w")
        data_file.write(contents)
        data_file.close()

    def _mdh_json(self, data):
        order = int(data["order"])
        id = int(data["id"][1])
        transitive_number = int(data["transitive number"])
        degree = int(data["degree"])
        transitivity = int(data["transitivity"])

        eigenvalues = functools.reduce(lambda a, b : a + [int(b[0]), int(b[1])], data["eigenvalues"], [])
        ekr = data["ekr"] 
        ekr_reasons = data["ekr reasons"]
        ekrm = data["ekrm"]
        ekrm_reasons = data["ekrm reasons"]
        sekr = data["sekr"] 
        sekr_reasons = data["sekr reasons"]
        
        abelian = data["abelian"]
        nilpotent = data["nilpotent"]
        primitive = data["primitive"]
        
        return [order,id,transitive_number,degree,transitivity,eigenvalues,abelian,nilpotent,primitive]
    
    def _save_mdh(self, list):
        dirpath = os.path.dirname(self.output)
        if os.path.exists(dirpath):
            assert os.path.isdir(dirpath), "{0} exists but is not a directory".format(dirpath)
        else:
            log.info("Creating directory: {0}".format(dirpath))
            pathlib.Path(dirpath).mkdir(parents=True, exist_ok=True)
        data_file = open(self.output, "w")
        data_file.write(json.dumps(list))
        data_file.close()

