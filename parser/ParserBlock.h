//
// ParserBlock.h
//
// Copyright (c) 2011 Lukhnos D. Liu (http://lukhnos.org)
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#ifndef PARSER_BLOCK_H
#define PARSER_BLOCK_H

#include <vector>
#include <string>
#include <sstream>
#include <map>
#include <set>
#include <string>

namespace Prolixity {
    class ParserBlock {
    private:
        std::string name;
        std::vector<std::string> vars;
        std::vector<std::string> instructions;
        std::vector<ParserBlock> blocks;
        std::string lastError;

		std::string simpleNumber;
        
        static const std::string obtainUniqueIdentifier(const std::string& type)
        {
            static std::map<std::string, size_t> counters;
            std::stringstream sst;
            sst << "%" << type << counters[type]++;
            return sst.str();
        }
    
    public:
		bool isSimpleNumberExp()
		{
			return simpleNumber.length() != 0 && instructions.size() == 1;
		}
		
        const std::string getSimpleNumber()
		{
			return simpleNumber;
		}
		
	
        const std::string obtainName()
        {
            name = obtainUniqueIdentifier("b");
            return name;
        }

        void mergeBlock(const ParserBlock& anotherBlock)
        {
            vars.insert(vars.end(), anotherBlock.vars.begin(), anotherBlock.vars.end());            
            instructions.insert(instructions.end(), anotherBlock.instructions.begin(), anotherBlock.instructions.end());
            blocks.insert(blocks.end(), anotherBlock.blocks.begin(), anotherBlock.blocks.end());
            if (anotherBlock.lastError.length()) {
                lastError = anotherBlock.lastError + "\n" + lastError;
            }
        }
        
        void recordError(const std::string& error)
        {
            if (lastError.length()) {
                lastError += "\n";
            }

            lastError += error;
        }
        
        void declareVariable(const std::string& name)
        {
            vars.push_back(name);
        }
        
        void addStore(const std::string& identifier)
        {
            std::string inst;
            inst += "store";
            inst += " ";
            inst += identifier;
            instructions.push_back(inst);
        }
        
        void addLoadNumber(const std::string& numberString)
        {
            std::stringstream sst;
            sst << "loadin";
            sst << " ";
            sst << numberString;
            instructions.push_back(sst.str());

			// TODO: Safe-guard this
			simpleNumber = numberString;
        }
        
        void addLoadString(const std::string& stringString)
        {            
            std::string inst = "loadis";
            inst += " \"";
            inst += stringString;
            inst += "\"";
            instructions.push_back(inst);
        }

		void addLoadPoint(const std::string& numberX, const std::string& numberY)
		{
            std::stringstream sst;
            sst << "loado_point";
            sst << " ";
			sst << numberX;
            sst << " ";
			sst << numberY;			
            instructions.push_back(sst.str());			
		}

		void addLoadSize(const std::string& numberX, const std::string& numberY)
		{
            std::stringstream sst;
            sst << "loado_size";
            sst << " ";
			sst << numberX;
            sst << " ";
			sst << numberY;			
            instructions.push_back(sst.str());			
		}

		void addLoadRange(const std::string& numberX, const std::string& numberY)
		{
            std::stringstream sst;
            sst << "loado_range";
            sst << " ";
			sst << numberX;
            sst << " ";
			sst << numberY;			
            instructions.push_back(sst.str());			
		}

		void addLoadRect4I(const std::string& numberX1, const std::string& numberY1, const std::string& numberX2, const std::string& numberY2)
		{
            std::stringstream sst;
            sst << "loado_rect";
            sst << " ";
			sst << numberX1;
            sst << " ";
			sst << numberY1;			
            sst << " ";
			sst << numberX2;
            sst << " ";
			sst << numberY2;			
            instructions.push_back(sst.str());			
		}
        
        void addLoad(const std::string& identifier)
        {
            std::string inst;
            inst += "load";
            inst += " ";
            inst += identifier;
            instructions.push_back(inst);
        }
        
        void addBlock(const ParserBlock& block)
        {
            blocks.push_back(block);
        }
        
        void addPush()
        {
            instructions.push_back("push");
        }
        
        void addInvoke(const std::string& methodName)
        {
            std::string inst;
            inst += "invoke";
            inst += " ";
            inst += methodName;
            instructions.push_back(inst);            
        }
        
        const std::string obtainTempVar()
        {
            std::string tempVar = obtainUniqueIdentifier("t");
            declareVariable(tempVar);
            return tempVar;
        }
        
        const std::string getName()
        {
            return name;
        }
        
        const std::string getLastError()
        {
            return lastError;
        }
        
        const std::string dump(size_t level = 0, size_t tabWidth = 4, char tabChar = ' ') const
        {
            std::string tab1(tabWidth * level, tabChar);
            std::string tab2(tabWidth * (level + 1), tabChar);
            std::stringstream sst;
            
            sst << tab1;
            sst << "block";
            sst << " ";

            if (name.length()) {
                sst << name;
            }
            else {
                sst << "%anonymous";
            }
            
            sst << "\n";
            
            for (std::vector<ParserBlock>::const_iterator bi = blocks.begin(), be = blocks.end() ; bi != be ; ++bi) {
                sst << (*bi).dump(level + 1, tabWidth, tabChar);
            }
            
            for (std::vector<std::string>::const_iterator vi = vars.begin(), ve = vars.end() ; vi != ve ; ++vi) {
                sst << tab2 << "var" << " " << *vi << "\n";
            }
            
            for (std::vector<std::string>::const_iterator ii = instructions.begin(), ie = instructions.end() ; ii != ie ; ++ii) {
                sst << tab2 << *ii << "\n";
            }
            
            sst << tab1;
            sst << "end";
            sst << "\n";
            
            return sst.str();
        }
    };                
};

#endif
