classdef EMUNetworkEnumerator < handle
    % EMUNETWORKENUMERATOR Enumerates target and intermediate EMUs.

    properties (Access = private)
        TableEMU table
        TableEMUReaction table
        SearchedProducts cell = {}
        CharList = ['A':'Z' 'a':'z']
    end

    methods

        function result = enumerate(obj, source)

            arguments
                obj
                source (1, 1) openmebius.mfa.EMUNetworkSource
            end

            initialize(obj);
            errorMessages = validateMSReactions(obj, source.MSReactions);

            if isempty(errorMessages)
                enumerateTargets(obj, source);
                enumerateIntermediates(obj, source);
                obj.TableEMU = sortrows( ...
                    obj.TableEMU, ...
                    ["Size", "Metabolite", "EMU"], ...
                    ["descend", "ascend", "ascend"]);
                obj.TableEMUReaction = sortrows( ...
                    obj.TableEMUReaction, ...
                    ["Size", "RxnID"], ...
                    ["descend", "ascend"]);
            end

            result = openmebius.mfa.EMUNetworkEnumerationResult( ...
                TableEMU = obj.TableEMU, ...
                TableEMUReaction = obj.TableEMUReaction, ...
                SearchedProducts = obj.SearchedProducts, ...
                ErrorMessages = errorMessages);

        end % enumerate

    end % methods

    methods (Access = private)

        function initialize(obj)

            obj.TableEMU = openmebius.mfa.EMUNetworkEnumerator ...
                .emptyEMUTable();
            obj.TableEMUReaction = openmebius.mfa.EMUNetworkEnumerator ...
                .emptyEMUReactionTable();
            obj.SearchedProducts = {};

        end % initialize

        function errorMessages = validateMSReactions(~, msReactions)

            errorMessages = strings(0, 1);

            for row = 1:height(msReactions)
                products = msReactions.Products{row};
                isInvalid = size(products, 2) > 1 || ...
                    ~strcmp(products{1}, ...
                        msReactions.Properties.RowNames{row});

                if isInvalid
                    errorMessages(end + 1, 1) = ...
                        "EMUModel: More than one product or no reactant."; %#ok<AGROW>
                end
            end

        end % validateMSReactions

        function enumerateTargets(obj, source)

            msReactions = source.MSReactions;
            msTransitions = source.MSTransitions;

            for row = 1:height(msTransitions)
                targetMetabolite = msReactions.Products{row}{1};
                targetAtomString = msTransitions.Products{row}{1};
                targetNumAtoms = strlength(targetAtomString);
                targetPosition = 1:targetNumAtoms;
                arrangedAtoms = obj.CharList(1:targetNumAtoms);
                targetEMU = openmebius.mfa.EMUNetworkEnumerator ...
                    .emuLabel(targetMetabolite, arrangedAtoms);
                products = {targetEMU};
                reactants = {};

                if strlength(targetAtomString) == 0
                    continue
                end

                addEMU( ...
                    obj, targetEMU, targetMetabolite, ...
                    targetPosition, targetNumAtoms, true);

                for reactantIndex = 1:numel(msTransitions.Reactants{row})
                    reactantMetabolite = ...
                        msReactions.Reactants{row}{reactantIndex};
                    reactantAtomString = ...
                        msTransitions.Reactants{row}{reactantIndex};
                    reactantNumAtoms = strlength(reactantAtomString);
                    reactantPosition = ...
                        openmebius.mfa.EMUNetworkEnumerator.atomPosition( ...
                            reactantAtomString, targetAtomString);
                    arrangedReactantAtoms = ...
                        obj.CharList(1:reactantNumAtoms);
                    arrangedPosition = ...
                        arrangedReactantAtoms(reactantPosition);
                    reactantEMU = openmebius.mfa.EMUNetworkEnumerator ...
                        .emuLabel(reactantMetabolite, arrangedPosition);

                    if strlength(reactantAtomString) == 0 || ...
                            isempty(reactantPosition)
                        continue
                    end

                    reactants{end + 1} = reactantEMU; %#ok<AGROW>
                    addEMU( ...
                        obj, reactantEMU, reactantMetabolite, ...
                        reactantPosition, numel(reactantPosition), false);
                end

                addReaction( ...
                    obj, ...
                    msReactions.Properties.RowNames{row}, ...
                    reactants, products, 1, targetNumAtoms, true);
            end

        end % enumerateTargets

        function enumerateIntermediates(obj, source)

            targetReactions = obj.TableEMUReaction;
            obj.SearchedProducts = targetReactions.Products;

            for reactionIndex = 1:height(targetReactions)
                reactants = targetReactions.Reactants{reactionIndex};

                for reactantIndex = 1:length(reactants)
                    reactantEMU = reactants{reactantIndex};

                    if isSearchedProduct(obj, reactantEMU)
                        continue
                    end

                    emuRow = obj.TableEMU( ...
                        obj.TableEMU.EMU == reactantEMU, :);
                    searchEMU(obj, source, reactantEMU, false, emuRow);
                end
            end

        end % enumerateIntermediates

        function isSearched = isSearchedProduct(obj, productEMU)

            isSearched = false;

            for index = 1:length(obj.SearchedProducts)
                if isequal(obj.SearchedProducts{index}, productEMU)
                    isSearched = true;
                    break
                end
            end

            if ~isSearched
                obj.SearchedProducts{end + 1} = productEMU;
            end

        end % isSearchedProduct

        function searchEMU( ...
                obj, source, emuName, continueFlag, emuTable)

            isAlreadyListed = obj.TableEMU.EMU == emuName;

            if any(isAlreadyListed) && continueFlag
                return
            end

            metabolite = emuTable.Metabolite(emuTable.EMU == emuName);
            position = emuTable.Position{emuTable.EMU == emuName};
            addEMU( ...
                obj, emuName, metabolite, position, ...
                length(position), false);

            if openmebius.mfa.EMUNetworkEnumerator.isSubstrate( ...
                    source.Metabolites, metabolite)
                return
            end

            reactionRows = openmebius.mfa.EMUNetworkEnumerator ...
                .findProductReactions(source.Reactions, metabolite);
            reactions = source.Reactions(reactionRows, :);
            transitions = source.Transitions(reactionRows, :);

            for reactionIndex = 1:height(reactions)
                for productIndex = 1:length( ...
                        transitions.Products{reactionIndex})
                    coefficient = 1;
                    productMetabolite = ...
                        reactions.Products{reactionIndex}{productIndex};

                    if openmebius.mfa.EMUNetworkEnumerator.isSymmetric( ...
                            source.Metabolites, productMetabolite)
                        coefficient = coefficient / 2;
                    end

                    if ~strcmp(metabolite, string(productMetabolite))
                        continue
                    end

                    productAtoms = ...
                        transitions.Products{reactionIndex}{productIndex};
                    productAtoms = productAtoms(position);
                    reactantTable = parseReaction( ...
                        obj, source, emuName, productAtoms, ...
                        reactions(reactionIndex, :), ...
                        transitions(reactionIndex, :), coefficient);

                    for row = 1:height(reactantTable)
                        searchEMU( ...
                            obj, source, reactantTable.EMU{row}, ...
                            true, reactantTable);
                    end

                    if openmebius.mfa.EMUNetworkEnumerator.isSymmetric( ...
                            source.Metabolites, productMetabolite)
                        numAtoms = strlength( ...
                            transitions.Products{reactionIndex}{productIndex});
                        positionPattern = false(1, numAtoms);
                        positionPattern(position) = true;
                        symmetricPattern = flip(positionPattern);
                        symmetricProductAtoms = ...
                            transitions.Products{reactionIndex}{productIndex}( ...
                                symmetricPattern);
                        symmetricReactants = parseReaction( ...
                            obj, source, emuName, symmetricProductAtoms, ...
                            reactions(reactionIndex, :), ...
                            transitions(reactionIndex, :), coefficient);

                        for row = 1:height(symmetricReactants)
                            searchEMU( ...
                                obj, source, symmetricReactants.EMU{row}, ...
                                true, symmetricReactants);
                        end
                    end
                end
            end

        end % searchEMU

        function reactantTable = parseReaction( ...
                obj, source, emuName, productAtoms, ...
                reaction, transition, coefficient)

            emuSize = strlength(productAtoms);
            reactantTable = openmebius.mfa.EMUNetworkEnumerator ...
                .emptyEMUTable();
            reactantEMUs = {};
            numReactants = length(transition.Reactants{1});

            for reactantIndex = 1:numReactants
                reactantAtoms = ...
                    transition.Reactants{1}{reactantIndex};
                reactantMetabolite = ...
                    reaction.Reactants{1}{reactantIndex};
                position = openmebius.mfa.EMUNetworkEnumerator ...
                    .atomPosition(reactantAtoms, productAtoms);

                if isempty(position)
                    continue
                end

                if openmebius.mfa.EMUNetworkEnumerator.isSymmetric( ...
                        source.Metabolites, reactantMetabolite)
                    numAtoms = strlength(reactantAtoms);
                    positionPattern = false(1, numAtoms);
                    positionPattern(position) = true;
                    symmetricPattern = flip(positionPattern);

                    if find(positionPattern) >= find(symmetricPattern)
                        position = find(symmetricPattern);
                    end
                end

                reactantLabel = obj.CharList(sort(position));
                reactantEMU = openmebius.mfa.EMUNetworkEnumerator ...
                    .emuLabel(reactantMetabolite, reactantLabel);
                reactantEMUs{end + 1} = reactantEMU; %#ok<AGROW>
                reactantTable = [reactantTable; ...
                    {reactantEMU, reactantMetabolite, position, ...
                        numel(position), false}]; %#ok<AGROW>
            end

            addReaction( ...
                obj, reaction.Properties.RowNames{1}, ...
                reactantEMUs, {emuName}, coefficient, emuSize, false);

        end % parseReaction

        function addEMU( ...
                obj, emuName, metabolite, position, emuSize, isTarget)

            if any(obj.TableEMU.EMU == emuName) || emuSize == 0
                return
            end

            obj.TableEMU = [obj.TableEMU; ...
                {emuName, metabolite, position, emuSize, isTarget}];

        end % addEMU

        function addReaction( ...
                obj, reactionID, reactants, products, ...
                coefficient, emuSize, isTarget)

            row = { ...
                reactionID, {reactants}, {products}, ...
                coefficient, emuSize, isTarget};
            reaction = cell2table( ...
                row, ...
                VariableNames = ...
                    obj.TableEMUReaction.Properties.VariableNames);
            obj.TableEMUReaction = [obj.TableEMUReaction; reaction];

        end % addReaction

    end % methods (Access = private)

    methods (Static, Access = private)

        function tableEMU = emptyEMUTable()

            tableEMU = table( ...
                Size = [0, 5], ...
                VariableNames = ...
                    ["EMU", "Metabolite", "Position", "Size", "Target"], ...
                VariableTypes = ...
                    ["string", "string", "cell", "double", "logical"]);
            tableEMU.Properties.Description = "EMU table";

        end % emptyEMUTable

        function reactions = emptyEMUReactionTable()

            reactions = table( ...
                Size = [0, 6], ...
                VariableNames = [ ...
                    "RxnID", "Reactants", "Products", ...
                    "Coefficient", "Size", "Target"], ...
                VariableTypes = [ ...
                    "string", "cell", "cell", ...
                    "double", "double", "logical"]);
            reactions.Properties.Description = "EMU reaction table";

        end % emptyEMUReactionTable

        function emu = emuLabel(metabolite, position)

            if isempty(metabolite) || isempty(position)
                emu = "";
                return
            end

            metabolite = strrep(metabolite, '_', '-');
            position = strjoin(string(position), '');
            emu = sprintf('%s_{%s}', metabolite, position);

        end % emuLabel

        function position = atomPosition(reactant, product)

            position = [];

            if isempty(reactant) || isempty(product)
                return
            end

            for atomIndex = 1:strlength(product)
                matchingPosition = strfind(reactant, product(atomIndex));

                if ~isempty(matchingPosition)
                    position = [position, matchingPosition]; %#ok<AGROW>
                end
            end

        end % atomPosition

        function rows = findProductReactions(reactions, metabolite)

            rows = [];

            for row = 1:height(reactions)
                if ismember(metabolite, reactions.Products{row})
                    rows = [rows; row]; %#ok<AGROW>
                end
            end

        end % findProductReactions

        function tf = isSubstrate(metabolites, metabolite)

            substrateNames = metabolites.Metabolite( ...
                string(metabolites.Type) == "substrate");
            tf = ismember(metabolite, substrateNames);

        end % isSubstrate

        function tf = isSymmetric(metabolites, metabolite)

            row = strcmp(metabolites.Metabolite, metabolite);
            tf = metabolites.Symmetric{row};

        end % isSymmetric

    end % methods (Static, Access = private)

end % classdef
