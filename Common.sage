class Common:
    def __init__(self, group):
        self.group = group
        self.degree = group.degree()
        self.order = group.order()
        self.transitivity = gap.Transitivity(group)
        self.identity = group.one()

        self.characters = group.irreducible_characters()

        self.conjugacy_classes = group.conjugacy_classes()
        self.derangement_classes = self._get_derangement_classes()

        self.subgroups = group.conjugacy_classes_subgroups()

        (self.eigenvalues, self.eigenvalues_with_multiplicities) = self._get_eigenvalues()
        self.max_eigenvalue = gap.Maximum(self.eigenvalues)
        self.min_eigenvalue = gap.Minimum(self.eigenvalues)

        self.n_cliques = self._get_n_cliques()
        self.stabilizer_sized_cocliques = self._get_stabilizer_sized_cocliques()
        self.larger_than_stabilizer_cocliques = self._get_larger_than_stabilizer_cocliques()
    
    def _get_derangement_classes(self):
        conjugacy_classes = self.conjugacy_classes

        derangement_classes = []
        for conjugacy_class in conjugacy_classes:
            representative = conjugacy_class[0]
            if not Permutation(representative).fixed_points():
                derangement_classes.append(conjugacy_class)
        
        return derangement_classes


    def _get_eigenvalues(self):
        characters = self.characters
        derangement_classes = self.derangement_classes
        identity = self.identity

        eigenvalues = []
        eigenvalues_with_multiplicities = []
        for character in characters:
            eigenvalue_sum = 0
            eigenvalue_factor = (1/character(identity))
            for derangement_class in derangement_classes:
                representative = derangement_class[0]
                character_value = character(representative)
                eigenvalue_sum += len(derangement_class) * character_value

            eigenvalue = eigenvalue_factor * eigenvalue_sum
            eigenvalues.append(eigenvalue)
            eigenvalues_with_multiplicities += [eigenvalue] * int((character(identity) ** 2)) #we have to cast to an int here in order to "multiply" the array

        return (eigenvalues, eigenvalues_with_multiplicities)


    def _get_n_cliques(self):
        subgroups = self.subgroups
        n_subgroups = [subgroup for subgroup in subgroups if subgroup.order() == self.degree]

        n_cliques = []
        for subgroup in n_subgroups:
            eigenvalues = self._get_eigenvalues_subgroup(subgroup)
            minimum_eigenvalue = gap.Minimum(eigenvalues)

            if minimum_eigenvalue == -1:
                n_cliques.append(subgroup)

        return n_cliques


    def _get_stabilizer_sized_cocliques(self):
        subgroups = self.subgroups
        stabilizer_sized_subgroups = [subgroup for subgroup in subgroups if subgroup.order() == self.order/self.degree]

        stabilizer_sized_cocliques = []
        for subgroup in stabilizer_sized_subgroups:
            eigenvalues = self._get_eigenvalues_subgroup(subgroup)
            eigenvalue_is_zero = [eigenvalue == 0 for eigenvalue in eigenvalues]

            if all(eigenvalue_is_zero):
                stabilizer_sized_cocliques.append(subgroup)
        
        return stabilizer_sized_cocliques

    def _get_larger_than_stabilizer_cocliques(self):
        subgroups = self.subgroups
        larger_than_stabilizer_subgroups = [subgroup for subgroup in subgroups if subgroup.order() > self.order/self.degree]

        larger_than_stabilizer_cocliques = []
        for subgroup in larger_than_stabilizer_subgroups:
            eigenvalues = self._get_eigenvalues_subgroup(subgroup)
            eigenvalue_is_zero = [eigenvalue == 0 for eigenvalue in eigenvalues]

            if all(eigenvalue_is_zero):
                larger_than_stabilizer_cocliques.append(subgroup)
        
        return larger_than_stabilizer_cocliques


    #helper functions
    def _get_eigenvalues_subgroup(self, subgroup):
        characters = subgroup.irreducible_characters()
        conjugacy_classes = subgroup.conjugacy_classes()
        identity = subgroup.one()

        derangement_classes = []
        for conjugacy_class in conjugacy_classes:
            representative = conjugacy_class[0]
            if not Permutation(representative).fixed_points():
                derangement_classes.append(conjugacy_class)
        

        eigenvalues = []
        for character in characters:
            eigenvalue_sum = 0
            eigenvalue_factor = (1/character(identity))
            for derangement_class in derangement_classes:
                representative = derangement_class[0]
                character_value = character(representative)
                eigenvalue_sum += len(derangement_class) * character_value

            eigenvalue = eigenvalue_factor * eigenvalue_sum
            eigenvalues.append(eigenvalue)

        return eigenvalues