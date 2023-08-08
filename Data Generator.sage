import os
import functools
import json

class Data_Generator:
    def __init__(self, groups, mdh=False):
        groups_left = len(groups)
        all_data = []
        for group in groups:
            try:
                print(f"{group}")
                print("Determing common properties")
                common = Common(group)
                print("Common properties determined")

                print("Determining EKR property")
                ekr = EKR_Determiner(common)
                print("EKR property determined")

                print("Determining EKR-module property")
                ekrm = EKRM_Determiner(common, ekr)
                print("EKR-module property determined")

                print("Determining strict EKR property")
                strict_ekr = Strict_EKR_Determiner(common, ekr, ekrm)
                print("Strict EKR property determined")

                print("Saving data")
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
                    print(self._mdh_json(data))
                else:
                    self._save(data)
                print("Data saved")

                groups_left -= 1
                print(f"\n\n\nGroups left: {groups_left}")
        
            except Exception as e:
                print("ENCOUNTERED ERROR - CHECK errors.txt")
                error_log = open("errors.txt", "a")
                error_log.write(f"While checking the EKR properties of {group} we encountered the error {e}\n\n\n")
                error_log.close()

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

        data_file = open(f"Data/{degree}/{number}", "w")
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
        if not os.path.exists("Export"):
            os.makedirs("Export")
        data_file = open(f"Export/EKR_data.json", "w")
        data_file.write(json.dumps(list))
        data_file.close()

