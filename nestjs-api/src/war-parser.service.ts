import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import { exec } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';
import * as path from 'path';

const execAsync = promisify(exec);

@Injectable()
export class WarParserService {
  private readonly logger = new Logger(WarParserService.name);

  async processLogFile(filePath: string): Promise<any> {
    try {
      this.logger.log(`Iniciando processamento do log: ${filePath}`);
      
      // Encontra o caminho exato do script Ruby e do arquivo
      const runnerPath = path.resolve(__dirname, '../../ruby-engine/bin/runner.rb');
      const absoluteFilePath = path.resolve(filePath);

      // Chama o nosso motor Ruby passando o arquivo
      const { stdout, stderr } = await execAsync(`ruby "${runnerPath}" "${absoluteFilePath}"`);

      if (stderr) {
        this.logger.warn(`Avisos do Worker: ${stderr}`);
      }

      // Transforma o texto do Ruby em um objeto JSON real para a API
      const parsedData = JSON.parse(stdout);

      // Limpa o arquivo temporário
      fs.unlinkSync(absoluteFilePath);

      return {
        status: 'success',
        message: 'Batalhas processadas e ranqueadas com sucesso!',
        data: parsedData,
      };

    } catch (error) {
      this.logger.error('Erro ao processar o log', error.stack);
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
      throw new InternalServerErrorException('Falha ao processar o motor de ranking.');
    }
  }
}